namespace :data_hygiene do
  namespace :draft_content_id_cleanup do
    def run(cleanup: false)
      unless ENV["MONGODB_URI"]&.include?("draft")
        raise "This should only be run against the draft content store"
      end

      file_path = ENV.fetch("FILE_PATH")
      lines = File.read(file_path).split("\n")

      substitution_formats = %w(redirect gone unpublishing)

      lines.each do |line|
        hash = JSON.parse(line).fetch("content_item")
        item = ContentItem.where(base_path: hash.fetch("base_path")).first

        if hash.fetch("content_id").nil?
          raise "The file is missing content_ids. You need to generate them before dumping the file"
        end

        next unless item
        next if substitution_formats.include?(item.format)
        next if substitution_formats.include?(hash.fetch("format"))

        unless hash.fetch("content_id") == item.content_id
          puts "content_id mismatch: #{item.content_id} will be set to #{hash.fetch('content_id')}"
          puts "  (base_path: #{item.base_path})"
          puts

          item.set(content_id: hash.fetch("content_id")) if cleanup
        end
      end
    end

    desc "Report on content_id for items that mismatch with the given file"
    task report: [:environment] do
      run
    end

    desc "Clean the content_id for items that mismatch with the given file"
    task cleanup: [:environment] do
      run(cleanup: true)
    end
  end
end
