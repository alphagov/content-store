# Maps fields from a source Mongo JSON object
# into the corresponding field in our ActiveRecord models
class MongoFieldMapper
  MAPPINGS = {
    ContentItem => {
      rename: {
        "_id" => "base_path"
      },
      process: {
        "public_updated_at" => lambda{ |key, value| {key => value.try(:[], "$date")} },
        "first_published_at" => lambda{ |key, value| {key => value.try(:[], "$date")} },
        "created_at" => lambda{ |key, value| {key => value.try(:[], "$date")} },
        "updated_at" => lambda{ |key, value| {key => value.try(:[], "$date")} },
      }
    }
  }
  def initialize(model_class:, mongo_object:)
    @model_class = model_class
    @mongo_object = mongo_object
  end

  def active_record_attributes
    return @mongo_object.select{ |k, _| keep_this_key?(k) } unless MAPPINGS[@model_class]

    attrs = {}
    @mongo_object.each do |key, value|
      mapped_attr = process(key, value)
      this_key = mapped_attr.keys.first
      attrs[this_key] = mapped_attr.values.first if this_key
    end
    attrs
  end

  def process(key, value)
    if proc = MAPPINGS[@model_class][:process][key]
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