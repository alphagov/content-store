namespace :schema_validation do
  desc "validates all content items for a given format producing a report of errors"
  task :errors_for_format, [:schema_name] => :environment do |_t, args|
    schema_name = args[:schema_name]
    DataHygiene::SchemaValidator.new(schema_name).report_errors
  end
end
