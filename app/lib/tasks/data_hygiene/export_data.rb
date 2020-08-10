module Tasks
  module DataHygiene
    class ExportData
      def initialize(file, stdout)
        @file = file
        @stdout = stdout
      end

      def export_all
        total = ContentItem.count

        ContentItem.all.each.with_index(1) do |content_item, index|
          content_item_hash = content_item.as_json
          updated_at = content_item_hash.delete("updated_at")

          json = {
            updated_at: updated_at,
            content_item: content_item_hash,
          }.to_json

          file.puts(json)

          print_progress(index, total)
        end

        stdout.puts
      end

    private

      attr_reader :file, :stdout

      def print_progress(completed, total)
        percent_complete = ((completed.to_f / total) * 100).round
        percent_remaining = 100 - percent_complete

        stdout.print "\r"
        stdout.flush
        stdout.print "Progress [#{'=' * percent_complete}>#{'.' * percent_remaining}] (#{percent_complete}%)"
        stdout.flush
      end
    end
  end
end
