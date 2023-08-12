require "rails_helper"

describe JsonImporter do
  subject { JsonImporter.new(model_class:, file: "content-items.json", offline_table_class: model_class, batch_size:) }
  let(:model_class) { ContentItem }
  let(:batch_size) { 1 }
  let(:mock_connection) { double(ActiveRecord::Base.connection) }
  let(:offline_table_class) { double(ContentItem, connection: mock_connection, table_name: "offline_table") }

  before do
    allow(mock_connection).to receive(:execute)
  end

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
      before do
        allow(Rails.logger).to receive(:info)
      end

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
    before do
      allow(subject).to receive(:insert_lines)
      allow(subject).to receive(:update_model_table_from_offline_table)
      allow(offline_table_class).to receive(:insert_all)
    end

    context "for each line in the file" do
      before do
        allow(IO).to receive(:foreach).and_yield("line1").and_yield("line2")
        allow(offline_table_class).to receive(:insert_all)
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

        it "inserts the lines" do
          expect(subject).to receive(:insert_lines).once.with(%w[line1 line2])
          subject.call
        end
      end
    end
  end

  describe "#insert_lines" do
    before do
      allow(model_class).to receive(:primary_key).and_return(:model_primary_key)
    end

    it "inserts the lines into the offline table, unique by the primary key" do
      expect(offline_table_class).to receive(:insert_all).with(%w[line1 line2], unique_by: [:model_primary_key])
      subject.send(:insert_lines, %w[line1 line2])
    end
  end

  describe "#update_model_table_from_offline_table" do
    before do
      allow(model_class.connection).to receive(:execute)
      allow(model_class.connection).to receive(:truncate)
      allow(subject).to receive(:insert_select_statement).and_return("insert-select statement")
    end
    it "truncates the model_class table" do
      expect(model_class.connection).to receive(:truncate).with(model_class.table_name)
      subject.send(:update_model_table_from_offline_table)
    end

    it "executes the insert_select_statement" do
      expect(model_class.connection).to receive(:execute).with("insert-select statement")
      subject.send(:update_model_table_from_offline_table)
    end
  end

  describe "#insert_select_statement" do
    let(:return_value) { subject.send(:insert_select_statement) }

    it "inserts into the model_class table from the offline_class table" do
      expect(return_value).to match(/\s*INSERT INTO\s+#{model_class.table_name}.+SELECT.*FROM\s+#{offline_table_class.table_name}.*/im)
    end

    it "includes all the columns in the same order, except primary_key" do
      allow(model_class).to receive(:column_names).and_return(%w[column1 column2])
      allow(model_class).to receive(:primary_key).and_return("primary_key")
      expect(return_value).to match(/INSERT .*(column1,column2).*SELECT.*column1,column2.* FROM.*/im)
    end
  end

  describe "#drop_offline_table" do
    it "drops the offline table" do
      expect(mock_connection).to receive(:execute).with("DROP TABLE #{offline_table_class.table_name}")
      subject.send(:drop_offline_table)
    end
  end

  describe "#create_offline_table_class" do
    describe "the return value" do
      let(:return_value) { subject.send(:create_offline_table_class) }

      it "is a class" do
        expect(return_value).to be_a(Class)
      end

      it "is a subclass of model_class" do
        expect(return_value.ancestors).to include(model_class)
      end

      describe "the table_name" do
        it "has a prefix of offline_import_" do
          expect(return_value.table_name).to start_with("offline_import_")
        end

        it "includes the model_class table_name" do
          expect(return_value.table_name).to match(/.*_#{model_class.table_name}_.*/)
        end

        it "ends in an 8-char hex string" do
          expect(return_value.table_name).to match(/.*_[a-f0-9]{8}/)
        end
      end
    end

    it "creates the offline table" do
      expect(subject).to receive(:create_offline_table)
      subject.send(:create_offline_table_class)
    end
  end
end
