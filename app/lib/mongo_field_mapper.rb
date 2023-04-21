# Maps fields from a source Mongo JSON object
# into the corresponding field in our ActiveRecord models
class MongoFieldMapper
  MAPPINGS = {
    ContentItem => {
      rename: {
        "_id" => "base_path",
      },
      process: {
        "public_updated_at" => ->(key, value) { { key => value.try(:[], "$date") } },
        "first_published_at" => ->(key, value) { { key => value.try(:[], "$date") } },
        "created_at" => ->(key, value) { { key => value.try(:[], "$date") } },
        "updated_at" => ->(key, value) { { key => value.try(:[], "$date") } },
        "publishing_scheduled_at" => ->(key, value) { { key => value.try(:[], "$date") } },
      },
    },
  }.freeze
  def initialize(model_class)
    @model_class = model_class
  end

  def active_record_attributes(obj)
    return obj.select { |k, _| keep_this_key?(k) } unless MAPPINGS[@model_class]

    attrs = {}
    obj.each do |key, value|
      mapped_attr = process(key, value)
      this_key = mapped_attr.keys.first
      attrs[this_key] = mapped_attr.values.first if this_key
    end
    attrs
  end

private

  def process(key, value)
    if (proc = MAPPINGS[@model_class][:process][key])
      proc.call(key, value)
    else
      processed_key = target_key(key)
      keep_this_key?(processed_key) ? { processed_key => value } : {}
    end
  end

  def keep_this_key?(key)
    @model_class.attribute_names.include?(key)
  end

  def target_key(key)
    MAPPINGS[@model_class][:rename][key] || key
  end
end
