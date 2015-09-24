require "csv"
require "tasks/data_hygiene/duplicate_report"

namespace :data_hygiene do
  namespace :content_ids do
    desc "Generate a report of content items with duplicate content_ids"
    task full_report: [:environment] do
      Tasks::DataHygiene::DuplicateReport.new.full
    end

    desc "Generate a report of content_id duplicates among items with an EN locale"
    task en_locale: [:environment] do
      Tasks::DataHygiene::DuplicateReport.new.scoped_to(locale: 'en')
    end

    task es_locale: [:environment] do
      Tasks::DataHygiene::DuplicateReport.new.scoped_to(locale: 'es')
    end
  end
end
