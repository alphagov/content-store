require "rails_helper"

describe MongoFieldMapper do
  let(:model_class) { ContentItem }
  subject { described_class.new(model_class) }

  describe "#process" do
    let(:result) { subject.send(:process, key, value) }

    context "given a key which should be renamed" do
      let(:key)   { "_id" }
      let(:value) { "/base/path" }

      it "returns a Hash" do
        expect(result).to be_a(Hash)
      end

      it "returns the key mapped to its target name" do
        expect(result.keys).to eq(%w[base_path])
      end

      it "has the given value" do
        expect(result.values).to eq([value])
      end
    end

    context "given a key which should be processed" do
      let(:key)   { "public_updated_at" }
      let(:value) { { "$date" => "2019-06-21T11:52:37Z" } }

      it "returns a Hash" do
        expect(result).to be_a(Hash)
      end

      it "returns the key mapped to its target name" do
        expect(result.keys).to eq(%w[public_updated_at])
      end

      it "has the expected value after processing " do
        expect(result.values).to eq(["2019-06-21T11:52:37Z"])
      end
    end

    context "given a key which is not present in the attributes of model_class" do
      let(:key)   { "arbitrary_key" }
      let(:value) { "anything" }

      it "returns an empty Hash" do
        expect(result).to eq({})
      end
    end
  end

  describe "#active_record_attributes" do
    context "given an object with fields to be renamed, processed and dropped" do
      let(:mongo_object) do
        {
          "_uid" => "abc123",
          "_id" => "/some/base/path",
          "public_updated_at" => { "$date" => "2019-06-21T11:52:37Z" },
          "first_published_at" => { "$numberLong" => "-473385600000" },
          "other_field" => "other_value",
          "details" => "details value",
        }
      end

      let(:result) { subject.active_record_attributes(mongo_object) }

      it "returns a Hash" do
        expect(result).to be_a(Hash)
      end

      it "does not return any keys which are not in the attributes of the model_class" do
        expect(result.keys - model_class.attribute_names).to be_empty
      end

      it "renames all keys which should be renamed" do
        expect(result.keys).not_to include("_id")
        expect(result.keys).to include("base_path")
      end

      it "preserves the value of renamed keys" do
        expect(result["base_path"]).to eq(mongo_object["_id"])
      end

      it "processes any fields which should be processed" do
        expect(result["public_updated_at"]).to eq("2019-06-21T11:52:37Z")
        expect(result["first_published_at"]).to eq("1955-01-01T00:00:00Z")
      end

      it "does not change any fields which are not to be dropped, processed or renamed" do
        expect(result["details"]).to eq(mongo_object["details"])
      end
    end
  end

  describe ".unpack_datetime" do
    context "given a Hash of '$date => 'value'" do
      context "where value has timezone signifier Z" do
        it "returns the value with a Z" do
          expect(described_class.unpack_datetime({ "$date" => "2019-06-21T11:52:37Z" })).to eq("2019-06-21T11:52:37Z")
        end
      end
      context "where value has timezone signifier +00:00" do
        it "returns the value with a +00:00" do
          expect(described_class.unpack_datetime({ "$date" => "2019-06-21T11:52:37+00:00" })).to eq("2019-06-21T11:52:37+00:00")
        end
      end
    end

    context "given a Hash of '$numberLong => value" do
      it "returns the value in iso8601 format" do
        expect(described_class.unpack_datetime({ "$numberLong" => -473_385_600_000 })).to eq("1955-01-01T00:00:00Z")
      end
    end

    context "given a Hash of '$numberLong => \"value\"" do
      it "returns the value in iso8601 format" do
        expect(described_class.unpack_datetime({ "$numberLong" => "-473385600000" })).to eq("1955-01-01T00:00:00Z")
      end
    end

    context "given nil" do
      it "returns nil" do
        expect(described_class.unpack_datetime(nil)).to be_nil
      end
    end

    # as seen in
    #  /government/publications/agreement-regarding-the-status-of-forces-of-parties-to-the-north-atlantic-treaty
    # "first_published_at":{"$date":{"$numberLong":"-473385600000"}}
    context "given a hash of hashes" do
      it "returns the final value" do
        expect(described_class.unpack_datetime({ "$date" => { "$numberLong" => "-473385600000" } })).to eq("1955-01-01T00:00:00Z")
      end
    end
  end
end
