require "rails_helper"

describe JsonImporter do
  subject { JsonImporter.new(model_class:, file: "content-items.json", batch_size:) }
  let(:model_class) { ContentItem }
  let(:batch_size) { 1 }

  describe "#exists?" do
    subject { JsonImporter.new(model_class:, file: "") }

    context "when @model_class is a ContentItem" do
      let(:model_class) { ContentItem }

      context "and the given id does not exist in the DB as a base_path" do
        let(:id) { "/no/base/path/here" }

        it "returns false" do
          expect(subject.send(:exists?, id)).to eq(false)
        end
      end

      context "and the  given id does exist in the DB as a base_path" do
        let(:id) { create(:content_item).base_path }

        it "returns true" do
          expect(subject.send(:exists?, id)).to eq(true)
        end
      end
    end

    context "when @model_class is not a ContentItem" do
      let(:model_class) { User }

      context "and no @model_class with the given id exists" do
        let(:id) { 9_999_999 }

        it "returns false" do
          expect(subject.send(:exists?, id)).to eq(false)
        end
      end

      context "and the model exists in the DB" do
        let(:id) { create(:user).id }

        it "returns true" do
          expect(subject.send(:exists?, id)).to eq(true)
        end
      end
    end
  end

  describe "#log" do
    context "when given some arguments" do
      let(:args) { ["string to log", %w[an array]] }

      it "logs a tab-separated line of the arguments, with the timestamp at the start" do
        Timecop.freeze do
          timestamp = Time.zone.now.iso8601
          expect(Rails.logger).to receive(:info).with([timestamp, "string to log", "an", "array"].join("\t"))
          subject.send(:log, args)
        end
      end
    end
  end

  describe "#id_value" do
    context "when given a nested hash" do
      let(:obj) { { "_id" => { "$oid" => "12345" } } }

      it "returns the value of the _id=>$oid key" do
        expect(subject.send(:id_value, obj)).to eq("12345")
      end
    end

    context "when given a single-level hash" do
      let(:obj) { { "_id" => "12345" } }

      it "returns the value of the _id key" do
        expect(subject.send(:id_value, obj)).to eq("12345")
      end
    end
  end

  describe "#process_line" do
    context "when given a line of JSON" do
      let(:line) do
        {
          id: "1234",
          base_path: "/my/base/path",
          key2: { key2_sub1: "key2 sub1", key2_sub2: "key2 sub2" },
          title: "My title",
        }.to_json
      end

      it "returns the keys (stringified) & values that match the ActiveRecord attributes of the model_class" do
        expect(subject.send(:process_line, line)).to eq("id" => "1234", "base_path" => "/my/base/path", "title" => "My title")
      end
    end
  end

  describe "#is_an_application_model?" do
    let(:return_value) { subject.send(:is_an_application_model?, klass) }

    context "when given a class that is a descendant of ApplicationRecord" do
      let(:klass) { User }

      it "returns true" do
        expect(return_value).to eq(true)
      end
    end

    context "when given a class that is not a descendant of ApplicationRecord" do
      let(:klass) { Hash }

      it "returns false" do
        expect(return_value).to eq(false)
      end
    end
  end

  describe "#to_class" do
    context "when given a file name that maps to a class name" do
      let(:file) { "content-items.json" }

      it "returns the class" do
        expect(subject.send(:to_class, file)).to eq(ContentItem)
      end
    end

    context "when given a file name that does not map to a class name" do
      let(:file) { "Untitled FINAL - Final (2).doc" }

      it "returns nil" do
        expect(subject.send(:to_class, file)).to be_nil
      end
    end
  end

  describe "#infer_model_class" do
    context "when given a file name that maps to a class name" do
      context "and the class is not a descendant of ApplicationRecord" do
        let(:file) { "hashes.json" }

        it "returns nil" do
          expect(subject.send(:infer_model_class, file)).to be_nil
        end
      end

      context "and the class is a descendant of ApplicationRecord" do
        let(:file) { "content-items.json" }

        it "returns the class" do
          expect(subject.send(:infer_model_class, file)).to eq(ContentItem)
        end
      end
    end

    context "when given a file name that does not map to a class name" do
      let(:file) { "thingies.json" }

      it "returns nil" do
        expect(subject.send(:infer_model_class, file)).to be_nil
      end
    end
  end

  describe ".import_file" do
    let(:path) { "/my/path" }
    before do
      allow(described_class).to receive(:new).and_return(subject)
      allow(subject).to receive(:call)
    end

    it "creates a new JsonImporter, passing the given path" do
      expect(described_class).to receive(:new).with(file: path).and_return(subject)
      described_class.import_file(path)
    end

    it "calls the new JsonImporter" do
      expect(subject).to receive(:call)
      described_class.import_file(path)
    end
  end

  describe ".import_all_in" do
    let(:path) { "/my/path" }
    before do
      allow(Dir).to receive(:glob).and_return(%w[file1 file2])
      allow(described_class).to receive(:import_file)
    end

    it "globs the given directory for json files" do
      expect(Dir).to receive(:glob).with("*.json", base: "/my/path").and_return(%w[file1 file2])
      described_class.import_all_in(path)
    end

    it "imports all files in that directory" do
      expect(described_class).to receive(:import_file).with("/my/path/file1").ordered
      expect(described_class).to receive(:import_file).with("/my/path/file2").ordered
      described_class.import_all_in(path)
    end
  end

  describe "#call" do
    context "for each line in the file" do
      before do
        allow(IO).to receive(:foreach).and_yield("line1").and_yield("line2")
        allow(ContentItem).to receive(:insert_all)
      end

      it "processes the line" do
        expect(subject).to receive(:process_line).with("line1").ordered
        expect(subject).to receive(:process_line).with("line2").ordered
        subject.call
      end

      context "when it has processed batch_size lines" do
        let(:batch_size) { 2 }
        before do
          allow(subject).to receive(:process_line).with("line1").and_return("line1")
          allow(subject).to receive(:process_line).with("line2").and_return("line2")
        end

        it "calls insert_all on the model_class" do
          expect(ContentItem).to receive(:insert_all).once.with(%w[line1 line2])
          subject.call
        end
      end
    end
  end
end
