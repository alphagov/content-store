class MongoExporter
  def self.collection_names
    Mongoid.default_client.collections.map(&:name).reject { |e| e == "data_migrations" }.sort
  end

  def self.export(collection:, path:)
    FileUtils.mkdir_p(path)
    zipped_file_path = File.join(path, [collection, "json", "gz"].join("."))
    execute(
      "mongoexport",
      "--uri=#{ENV['MONGODB_URI']}",
      "--collection=#{collection}",
      "--type=json",
      " | gzip > #{zipped_file_path}",
    )
  end

  def self.export_all(path:)
    collection_names.each do |collection|
      export(collection:, path:)
    end
  end

  def self.execute(cmd, *args)
    system cmd, *args
  end
end
