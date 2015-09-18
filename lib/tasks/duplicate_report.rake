require "csv"

desc "spit out a report of content items with duplicate content_ids"
task dupe_cids: [:environment] do
  puts "Counting content IDs and fetching duplicate occurrences..."
  content_id_counts = ContentItem.collection.aggregate([
    {
      "$group" => {
        "_id" => "$content_id", "count" => {"$sum" => 1}
      }
    },
    {
      "$match" => { "count" => {"$gt" => 1} }
    }
  ])

  puts "Fetching content items for duplicated content ids..."
  content_items = content_id_counts.flat_map do |cid_count|
    ContentItem.where(content_id: cid_count["_id"]).to_a
  end

  puts "Writing content items to csv..."
  current_time = Time.now.strftime("%Y-%m-%d-%I-%M")
  CSV.open("tmp/duplicate_content_ids_#{current_time}.csv", 'wb') do |csv|
    content_item_fields = [
      "_id", "content_id", "title", "format", "locale", "publishing_app",
      "rendering_app", "routes", "redirects", "phase", "analytics_identifier",
      "updated_at"
    ]

    csv << content_item_fields
    content_items.each do |content_item|
      csv << content_item_fields.map do |field|
        content_item.send("#{field}")
      end
    end
  end
end
