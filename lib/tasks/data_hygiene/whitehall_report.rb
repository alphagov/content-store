require "csv"

module WhitehallReport
  def self.run(csv_path)
    matched_content_items = []
    in_whitehall_but_not_in_content_store = []
    no_whitehall_content_id = []
    no_content_store_content_id = []
    mismatched_content_id = []

    CSV.foreach(csv_path, headers: true) do |row|
      whitehall_db_id = row["whitehall_db_id"]
      content_id = row["content_id"]
      base_path = row["base_path"]
      locale = row["locale"]
      state = row["state"]
      model = row["model"]
      updated_at = row["updated_at"]

      content_item = ContentItem.where(
        publishing_app: "whitehall",
        base_path: base_path
      ).first

      unless content_item
        in_whitehall_but_not_in_content_store << OpenStruct.new(
          content_id: content_id,
          base_path: base_path,
          format: model,
          locale: locale,
          updated_at: updated_at
        )
        next
      end

      matched_content_items << content_item

      unless content_id
        no_whitehall_content_id << content_item
        next
      end

      unless content_item.content_id
        no_content_store_content_id << content_item
        next
      end

      if content_id != content_item.content_id
        mismatched_content_id << content_item
        next
      end
    end

    matched_content_items.uniq!

    in_content_store_but_not_in_whitehall = ContentItem.where(
      publishing_app: 'whitehall',
      :id.nin => matched_content_items.map(&:id),
      :format.ne => "special_route"
    ).to_a

    redirects_with_new_content_ids, in_content_store_but_not_in_whitehall = slice_off_items_for_format!(
      in_content_store_but_not_in_whitehall, "redirect"
    )

    coming_soons_with_new_content_ids, in_content_store_but_not_in_whitehall = slice_off_items_for_format!(
      in_content_store_but_not_in_whitehall, "coming_soon"
    )

    gones_with_new_content_ids, in_content_store_but_not_in_whitehall = slice_off_items_for_format!(
      in_content_store_but_not_in_whitehall, "gone"
    )

    output(in_whitehall_but_not_in_content_store, "in_whitehall_but_not_in_content_store")
    output(in_content_store_but_not_in_whitehall, "in_content_store_but_not_in_whitehall")
    in_content_store_but_not_in_whitehall.group_by(&:format).each do |format, items|
      total = ContentItem.where(publishing_app: "whitehall", format: format).count
      percent = (items.size.to_f / total * 100).round(2)
      puts "  - #{items.size} items for #{format} (#{percent}%)"
    end
    output(mismatched_content_id, "mismatched_content_id")
    output(no_whitehall_content_id, "no_whitehall_content_id")
    output(no_content_store_content_id, "no_content_store_content_id")
    output(redirects_with_new_content_ids, "redirects_with_new_content_ids")
    output(coming_soons_with_new_content_ids, "coming_soons_with_new_content_ids")
    output(gones_with_new_content_ids, "gones_with_new_content_ids")
  end

  def self.output(content_items, filename)
    path = "tmp/#{filename}.txt"

    File.open(path, "w") do |file|
      content_items.each do |item|
        file.puts "#{item.content_id}, #{item.base_path}, #{item.format}, #{item.locale}, #{item.updated_at}"
      end
    end

    puts "Written #{content_items.size} lines to #{path}"
  end

  def self.slice_off_items_for_format!(content_items, format)
    format_items, everything_else = content_items.partition do |item|
      item.format == format && item.content_id.blank?
    end

    [format_items, everything_else]
  end
end
