require "csv"
require "ostruct"

module DataHygiene
  class DuplicateReport
    attr_accessor :summary

    def initialize
      @summary = OpenStruct.new
    end

    def scoped_to(locale:)
      # Count all duplicate content IDs and add count to summary
      summary.blank_content_ids = ContentItem.where(content_id: nil).count
      duplicates = fetch_all_duplicate_content_items
      summary.duplicates = duplicates.count

      # Identify duplicate (content_id, locale) tuples and add count to summary
      duplicates.select! { |ci| ci.locale == locale }
      content_id_counts = count_repeated_content_ids_in(duplicates)
      duplicates_for_locale = content_id_counts.flat_map do |content_id_count|
        ContentItem.where(content_id: content_id_count.first, locale:).to_a
      end
      summary.duplicates_for_locale = duplicates_for_locale.count

      write_to_csv(duplicates_for_locale, locale)
      summarise
    end

    def full
      summary.blank_content_ids = ContentItem.where(content_id: nil).count
      duplicates = fetch_all_duplicate_content_items
      summary.duplicates = duplicates.count

      write_to_csv(duplicates)
      summarise
    end

  private

    def fetch_all_duplicate_content_items
      logger.info "Fetching content items for duplicated content ids..."
      duplicates = duplicate_content_id_aggregation.flat_map do |content_id_count|
        ContentItem.where(content_id: content_id_count.content_id).to_a
      end
      duplicates.compact
    end

    def duplicate_content_id_aggregation
      @duplicate_content_id_aggregation ||= ContentItem
        .select('content_id, count(*) as num_records')
        .where('content_id IS NOT NULL')
        .group(:content_id)
        .having('count(*) > 1')
    end

    def count_repeated_content_ids_in(content_items)
      # Return a hash of the form { "myC00lc0ntentID" => 3 }"
      content_id_counts = content_items.each_with_object(Hash.new(0)) do |ci, hash|
        hash[ci.content_id] += 1
      end
      content_id_counts.select { |_k, v| v > 1 }
    end

    def summarise
      logger.info "~~~~~~~~~\n Summary \n~~~~~~~~~\n"
      summary.each_pair do |attr, val|
        logger.info "#{attr}: #{val}"
      end
    end

    def write_to_csv(content_items, locale = nil)
      logger.info "Writing content items to csv..."
      current_time = Time.zone.now.strftime("%Y-%m-%d-%H-%M")
      filename = "duplicate_content_ids_#{current_time}"
      filename = "#{locale}_#{filename}" if locale

      CSV.open("tmp/#{filename}.csv", "wb") do |csv|
        content_item_fields = %w[
          _id
          content_id
          title
          document_type
          schema_name
          locale
          publishing_app
          rendering_app
          routes
          redirects
          phase
          analytics_identifier
          updated_at
        ]

        csv << content_item_fields
        content_items.each do |content_item|
          csv << content_item_fields.map do |field|
            content_item.send(field.to_s)
          end
        end
      end
    end
  end
end
