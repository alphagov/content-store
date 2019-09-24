module Tasks
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

            duplicate.destroy if do_destroy
          end
        end

        report
      end

      # Produce an array of arrays containing duplicate ContentItems
      def fetch_duplicates_arrays
        [].tap do |ary|
          duplicate_content_id_aggregation.each do |content_id_count|
            ary << ContentItem.where(
              content_id: content_id_count["_id"]["content_id"],
              locale: content_id_count["_id"]["locale"],
            ).to_a
          end
        end
      end

      # Fetch a count of all content items with content ids / locale duplicates.
      def duplicate_content_id_aggregation
        @duplicate_content_id_aggregation ||= ContentItem.collection.aggregate([
          {
            "$group" => {
              "_id" => { "content_id" => "$content_id", "locale" => "$locale" },
              "uniqueIds" => { "$addToSet" => "$_id" },
              "count" => { "$sum" => 1 },
            },
          },
          { "$match" => { "_id.content_id" => { "$ne" => nil }, "count" => { "$gt" => 1 } } },
        ])
      end

      def report
        aux_verb = do_destroy ? "were" : "would be"
        puts "These duplicates #{aux_verb} destroyed..."
        puts deduplicated.join("\n")

        puts "-----------------------------------------------------------------"

        puts "These records #{aux_verb} preserved..."
        puts preserved.join("\n")

        puts "-----------------------------------------------------------------"

        puts "#{total} duplicates found."
        puts "#{preserved.size} records #{aux_verb} removed."
        puts "#{deduplicated.size} records #{aux_verb} preserved."
      end
    end
  end
end
