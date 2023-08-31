require "open3"

class MongoExporter
  def self.collection_names
    Mongoid.default_client.collections.map(&:name).reject { |e| e == "data_migrations" }.sort
  end

  def self.export(collection:, path:)
    FileUtils.mkdir_p(path)
    zipped_file_path = File.join(path, [collection, "json", "gz"].join("."))
    cmd1 = [
      "mongoexport",
      "--uri=#{ENV['MONGODB_URI']}",
      "--collection=#{collection}",
      "--type=json",
    ]
    cmd2 = ["gzip > #{zipped_file_path}"]
    execute_piped(cmd1, cmd2)
  end

  def self.export_all(path:)
    collection_names.each do |collection|
      export(collection:, path:)
    end
  end

  # Run the given commands as a pipeline (cmd1 | cmd2 | ...)
  def self.execute_piped(*args)
    Open3.pipeline(*args)
  end
end
