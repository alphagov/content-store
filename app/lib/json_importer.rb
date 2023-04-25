# Designed for importing JSON from MongoDB's mongoexport tool
# In this format, each line is one complete JSON object
# There is no surrounding array delimiter, or separating comma
# e.g.
# {"_id": "abc123", "field": "value1"}
# {"_id": "def456", "field": "value2"}
# and so on

class JsonImporter
  def initialize(model_class:, file:)
    @model_class = model_class.constantize
    @mapper = MongoFieldMapper.new(@model_class)
    @file = file
  end

  def call
    line_no = 0
    IO.foreach(@file) do |line|
      log line_no, "Processing"
      process_line(line)
      log line_no, "Completed"
      line_no += 1
    end
  end

private

  def process_line(line)
    log("parsing...")
    obj = JSON.parse(line)
    id = id_value(obj)
    log(id, " checking existence")
    if exists?(id)
      log(id, " exists, skipping")
    else
      log(id, " saving ")
      @model_class.insert(@mapper.active_record_attributes(obj))
      log(id, "saved")
    end
  end

  def id_value(obj)
    if obj["_id"].is_a?(Hash)
      obj["_id"]["$oid"]
    else
      obj["_id"]
    end
  end

  def exists?(id)
    if @model_class == ContentItem
      ContentItem.where(base_path: id).exists?
    else
      @model_class.where(id: id).exists?
    end
  end

  def log(*args)
    line = args.prepend(Time.zone.now.iso8601).join("\t")
    Rails.logger.info line
  end
end
