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
    log("assigning attributes to #{@model_class}...")
    model = @model_class.new
    mapper = MongoFieldMapper.new(model_class: @model_class, mongo_object: obj)
    processed_attributes = mapper.active_record_attributes
    model.assign_attributes(processed_attributes)
    log("saving...")
    model.save!(touch: false)
    log("saved")
  end

  def log(*args)
    line = args.prepend(Time.now.iso8601).join("\t")
    puts(line)
  end
end