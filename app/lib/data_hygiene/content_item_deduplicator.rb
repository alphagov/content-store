module DataHygiene
  class ContentItemDeduplicator
    attr_reader :do_destroy, :total, :deduplicated, :preserved

    def report_duplicates
      @do_destroy = false
      process_duplicates
    end

    def deduplicate
      @do_destroy = true
      process_duplicates
    end

  private

    def process_duplicates
      @deduplicated = []
      @preserved = []

      # Iterate each array of dupes sorting them by updated_at
      # preserving the latest record and destroying the rest
      duplicates = fetch_duplicates_arrays
      @total = duplicates.flatten.size

      duplicates.each do |duplicate_set|
        # Sort by updated_at and preserve the latest record.
        duplicate_set.sort! { |x, y| x.updated_at <=> y.updated_at }
        latest = duplicate_set.pop
        @preserved << "#{latest.content_id},#{latest.locale},#{latest.updated_at},#{latest.base_path}"

        # Usually this is a single item array as we typically have pairs of duplicates.
        duplicate_set.each do |duplicate|
          @deduplicated << "#{duplicate.content_id},#{duplicate.locale},#{duplicate.updated_at},#{duplicate.base_path}"

          duplicate.destroy! if do_destroy
        end
      end

      report
    end

    # Produce an array of arrays containing duplicate ContentItems
    def fetch_duplicates_arrays
      duplicate_content_id_aggregation.map do |row|
        ContentItem.where(content_id: row.content_id, locale: row.locale).to_a
      end
    end

    # Fetch a count of all content items with content ids / locale duplicates.
    def duplicate_content_id_aggregation
      @duplicate_content_id_aggregation ||= ContentItem
        .select("content_id, locale, count(*) as num_records")
        .where("content_id IS NOT NULL")
        .group("content_id, locale")
        .having("count(*) > 1")
    end

    def report
      aux_verb = do_destroy ? "were" : "would be"
      logger.info "These duplicates #{aux_verb} destroyed..."

      logger.info deduplicated.join("\n")

      logger.info "-----------------------------------------------------------------"

      logger.info "These records #{aux_verb} preserved..."
      logger.info preserved.join("\n")

      logger.info "-----------------------------------------------------------------"

      logger.info "#{total} duplicates found."
      logger.info "#{preserved.size} records #{aux_verb} removed."
      logger.info "#{deduplicated.size} records #{aux_verb} preserved."
    end
  end
end
