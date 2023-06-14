require "rails_helper"

describe MongoExporter do
  before do
    allow(MongoExporter).to receive(:execute).and_return(true)
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

    it "executes mongoexport" do
      expect(described_class).to receive(:execute).with("mongoexport", any_args)
      described_class.export(collection: "my_collection", path: "/my/path")
    end

    it "passes the correct mongoexport arguments" do
      expect(described_class).to receive(:execute).with(
        anything,
        "--uri=$MONGODB_URI",
        "--collection=my_collection",
        "--out=/my/path/my_collection.json",
        "--type=json",
      )
      described_class.export(collection: "my_collection", path: "/my/path")
    end
  end
end
