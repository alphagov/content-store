module DataHygiene
  class SchemaValidator
    def initialize(schema_name, log = $stdout)
      @schema_name = schema_name
      @log = log
    end

    def report_errors
      error_count = 0
      log.puts "Validating #{criteria.count} items with format '#{schema_name}'\n\n"

      File.open(report_path, "w") do |file|
        criteria.each do |item|
          validation_errors = validate(payload(item))
          if validation_errors.any?
            log.print "E"
            csv_row = [item.base_path, validation_errors].flatten.join(",")
            file.write("#{csv_row} \n")
            error_count += 1
          else
            log.print "."
          end
        end
      end

      log.puts "\n\n#{error_count} errors written to #{report_path}"
    end

  private

    attr_reader :schema_name, :log

    def criteria
      ContentItem.any_of(
        { schema_name: },
        { document_type: schema_name },
        { format: schema_name },
      )
    end

    def validate(payload)
      JSON::Validator.fully_validate(
        schema,
        payload,
      )
    end

    def payload(item)
      api_url_method = Rails.application.routes.url_helpers.method(:content_item_path)
      ContentItemPresenter.new(item, api_url_method).to_json
    end

    def schema
      prefix_path = Rails.env.development? ? "../govuk-content-schemas/dist" : "govuk-content-schemas"
      schema_path = "#{prefix_path}/formats/#{schema_name}/frontend/schema.json"
      @schema ||= JSON.parse(File.read(schema_path))
    end

    def report_path
      Rails.root.join("tmp", "#{schema_name}-validation-errors.csv")
    end
  end
end
