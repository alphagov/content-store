require "tasks/data_hygiene/content_item_deduplicator"

namespace :data_hygiene do
  namespace :content_items do
    desc "De-duplicate content items with matching content ids and locales by removing all but the latest record in each set of duplicates"
    task deduplicate: [:environment] do
      Tasks::DataHygiene::ContentItemDeduplicator.new.deduplicate
    end

    desc "Report on content items with matching content ids and locales"
    task report_duplicates: [:environment] do
      Tasks::DataHygiene::ContentItemDeduplicator.new.report_duplicates
    end
  end
end
