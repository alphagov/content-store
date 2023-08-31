require "rails_helper"

describe MongoExporter do
  before do
    allow(MongoExporter).to receive(:execute_piped).and_return(true)
    allow(FileUtils).to receive(:mkdir_p)
  end

  describe ".collection_names" do
    it "returns an array of collection names" do
      %w[content_items publish_intents scheduled_publishing_log_entries users].each do |coll|
        expect(described_class.collection_names).to include(coll)
      end
    end

    it "does not export data_migrations" do
      expect(described_class.collection_names).not_to include("data_migrations")
    end
  end

  describe ".export" do
    it "makes the given path if it does not exist" do
      expect(FileUtils).to receive(:mkdir_p).with("/my/path")
      described_class.export(collection: "my_collection", path: "/my/path")
    end

    it "executes mongoexport with the correct arguments" do
      expect(described_class).to receive(:execute_piped).with(
        ["mongoexport",
         "--uri=#{ENV['MONGODB_URI']}",
         "--collection=my_collection",
         "--type=json"],
        anything,
      )
      described_class.export(collection: "my_collection", path: "/my/path")
    end

    it "pipes the mongoexport output to gzip" do
      expect(described_class).to receive(:execute_piped).with(
        anything,
        ["gzip > /my/path/my_collection.json.gz"],
      )
      described_class.export(collection: "my_collection", path: "/my/path")
    end
  end
end
