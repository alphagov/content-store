desc <<DESCRIPTION
  Validate content items against their frontend schemas. Ignores formats without schemas.

  Optionally supply a comma separated list of format names to check.

  This assumes that govuk-content-schemas is in a sibling directory. Set
  GOVUK_CONTENT_SCHEMAS_PATH to override with a custom path.
DESCRIPTION
task :check_content_items_against_schema, [:format_names] => :environment do |_task, args|
  formats_to_use = if args[:format_names].present?
                     args[:format_names].split(",")
                   else
                     # placeholder items can have a format of
                     # 'placeholder' or 'placeholder_my_format_name'.
                     # redirect doesn't have a frontend schema.
                     (GovukSchemas::Schema.schema_names + [/\Aplaceholder_.+/]) - %w[redirect]
                   end

  validatable_content_items = ContentItem.where(:format.in => formats_to_use)
  api_url_callable = ->(base_path) { "http://api.example.com/content#{base_path}" }

  invalid_content_items = []

  puts "Validating #{validatable_content_items.count} content items"
  validatable_content_items.each do |content_item|
    presenter = ContentItemPresenter.new(content_item, api_url_callable)
    validator = GovukSchemas::Validator.new(content_item.format, "frontend", presenter.to_json)
    if validator.valid?
      print "."
    else
      invalid_content_items << [content_item, validator.errors]
      print "F"
    end
  end

  puts ""

  puts "Found #{invalid_content_items.size} invalid items"

  puts ""

  invalid_content_items.each do |content_item, errors|
    puts "#{content_item.base_path} format: #{content_item.format} has errors:"
    puts errors
    puts ""
    puts ""
  end
end
