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
    log(obj["_id"], " checking existence")
    if ContentItem.where(base_path: obj["_id"]).exists?
      log(obj["_id"], " exists, skipping")
    else
      log(obj["_id"], "assigning attributes to #{@model_class}...")
      model = process_attributes!(obj)
      log(obj["_id"], "saving...")
      model.save!(touch: false)
      log(obj["_id"], "saved")
    end
  end

  def process_attributes!(obj)
    model = @model_class.new
    processed_attributes = @mapper.active_record_attributes(obj)
    model.assign_attributes(processed_attributes)
    model
  end

  def log(*args)
    line = args.prepend(Time.zone.now.iso8601).join("\t")
    Rails.logger.info line
  end
end
