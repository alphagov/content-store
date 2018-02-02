task validate_content_against_schema: :environment do
  GovukContentSchemaTestHelpers.configure do |config|
    config.schema_type = 'frontend'
    config.project_root = Rails.root
  end

  schema_names = ContentItem.distinct(:schema_name).select(&:present?)
  puts "Will check #{schema_names}"

  reports = schema_names.map do |schema_name|
    validate_content_for_schema(schema_name)
  end

  total_checked = reports.sum { |r| r[:counts][:checked] }
  total_fail = reports.sum { |r| r[:counts][:fail] }
  failure_percentage = ((total_fail / total_checked.to_f) * 100).to_i

  GovukStatsd.gauge("document_validation.checked", total_checked)
  GovukStatsd.gauge("document_validation.fail", total_fail)
  GovukStatsd.gauge("document_validation.failure_percentage", failure_percentage)

  puts reports.to_yaml
end

def validate_content_for_schema(schema_name)
  api_url_callable = lambda { |base_path| "http://api.example.com/content#{base_path}" }

  # content_id ASC makes the sample semi-random
  items = ContentItem.order(content_id: :asc).where(schema_name: schema_name).limit(100)

  counts = { checked: 0, okay: 0, fail: 0 }
  errors = []

  items.each do |content_item|
    print '.'

    counts[:checked] += 1

    begin
      presenter = ContentItemPresenter.new(content_item, api_url_callable)
      validator = GovukContentSchemaTestHelpers::Validator.new(content_item.schema_name, "schema", presenter.to_json)

      if validator.valid?
        counts[:okay] += 1
      else
        counts[:fail] += 1
        errors << [content_item.base_path, validator.errors]
      end
    rescue GovukContentSchemaTestHelpers::ImproperlyConfiguredError => e
      errors << [content_item.base_path, e.message]
      counts[:fail] += 1
    end
  end

  { schema_name: schema_name, counts: counts, errors: errors }
end
