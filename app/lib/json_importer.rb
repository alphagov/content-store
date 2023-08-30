# Designed for importing JSON from MongoDB's mongoexport tool
# In this format, each line is one complete JSON object
# There is no surrounding array delimiter, or separating comma
# e.g.
# {"_id": "abc123", "field": "value1"}
# {"_id": "def456", "field": "value2"}
# and so on

class JsonImporter
  def initialize(file:, model_class: nil, offline_table_class: nil)
    @model_class = model_class || infer_model_class(file)
    raise ArgumentError, "Could not infer class from #{file}" unless @model_class

    @offline_table_class = offline_table_class || create_offline_table_class

    @mapper = MongoFieldMapper.new(@model_class)
    @file = file
  end

  def call
    line_no = 0
    log "Importing file #{@file}"

    begin
      # `gunzip -c` writes the gunzip output to STDOUT, `IO.popen` then
      # uses pipes to make that an IO stream in Ruby
      # see https://stackoverflow.com/a/31857743
      # Net result - we decompress and process a gzipped file line by line
      IO.popen({}, "gunzip -c #{@file}", "rb") do |io|
        while (line = io.gets)
          log line_no, "Processing"
          processed_line = process_line(line)
          log line_no, "Completed, saving..."
          insert_lines([processed_line])
          log line_no, "Saved"
          line_no += 1
        end
      end

      @model_class.transaction do
        update_model_table_from_offline_table
      end
    ensure
      drop_offline_table
    end
  end

  def self.import_all_in(path)
    files = Dir.glob("*.json.gz", base: path)
    files.each do |file|
      import_file(File.join(path, file))
    end
  end

  def self.import_file(path)
    new(file: path).call
  end

private

  def insert_lines(lines)
    @offline_table_class.insert_all(lines, unique_by: [@model_class.primary_key.to_sym], record_timestamps: false)
  end

  def update_model_table_from_offline_table
    log("truncating #{@model_class.table_name}")
    @model_class.connection.truncate(@model_class.table_name)
    log("insert-selecting all records from #{@offline_table_class.table_name} to #{@model_class.table_name}")
    @model_class.connection.execute insert_select_statement
  end

  def insert_select_statement
    # id is auto-generated - we have to exclude it from INSERT statements
    columns = @model_class.column_names - [@model_class.primary_key]
    <<-SQL
      INSERT INTO #{@model_class.table_name}
        (#{columns.join(',')})
      SELECT
        #{columns.join(',')}
      FROM #{@offline_table_class.table_name}
      ;
    SQL
  end

  def drop_offline_table
    @offline_table_class.connection.execute("DROP TABLE #{@offline_table_class.table_name}")
  end

  def create_offline_table_class
    klass = Class.new(@model_class)
    klass.table_name = "offline_import_#{@model_class.table_name}_#{SecureRandom.hex(4)}"
    log("creating table #{klass.table_name}")
    create_offline_table(klass)
    klass
  end

  def create_offline_table(klass)
    klass.connection.execute("CREATE TABLE #{klass.table_name} AS TABLE #{@model_class.table_name} WITH NO DATA")
    klass.connection.execute("CREATE UNIQUE INDEX ON #{klass.table_name} (#{@model_class.primary_key}) ")
  end

  def infer_model_class(file)
    klass = to_class(File.basename(file))
    klass && is_an_application_model?(klass) ? klass : nil
  end

  # Take a given file name like 'content-items.json' and convert it to
  # either a Class (if possible) or nil (if not)
  def to_class(file)
    file.split(".").first.underscore.classify.safe_constantize
  end

  def is_an_application_model?(klass)
    klass.ancestors.include?(ApplicationRecord)
  end

  def process_line(line)
    log("parsing...")
    obj = JSON.parse(line)
    log("id", id_value(obj))
    @mapper.active_record_attributes(obj)
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
      @model_class.where(id:).exists?
    end
  end

  def log(*args)
    line = args.prepend(Time.zone.now.iso8601).join("\t")
    Rails.logger.info line
  end
end
