require "json-schema"

class SchemaValidator
  def initialize(rendered_content_item)
    @rendered_content_item = rendered_content_item.deep_symbolize_keys
  end

  def validate
    return true if schema_name_exception?
    validate_schema
  end

private

  attr_reader :rendered_content_item

  def validate_schema
    JSON::Validator.validate!(schema, rendered_content_item)
  rescue JSON::Schema::ValidationError => error
    Airbrake.notify_or_ignore(error, parameters: {
      explanation: "#{rendered_content_item} schema validation error"
    })
    false
  end

  def schema
    File.read("#{schemas_directory}/formats/#{schema_name}/frontend/schema.json")
  rescue Errno::ENOENT => error
    Airbrake.notify_or_ignore(error, parameters: {
      explanation: "No frontend schema file for #{schema_name} #{rendered_content_item}"
    })
    return {}
  end

  def schema_name
    rendered_content_item[:schema_name] || rendered_content_item[:format]
  end

  def schema_name_exception?
    schema_name.to_s.match(/placeholder_/)
  end

  def schemas_directory
    if Rails.env.production?
      "govuk-content-schemas"
    else
      "../govuk-content-schemas/dist"
    end
  end
end
