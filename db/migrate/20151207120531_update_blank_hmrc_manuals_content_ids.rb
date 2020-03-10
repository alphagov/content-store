require "uuidtools"

class UpdateBlankHmrcManualsContentIds < Mongoid::Migration
  def self.up
    content_items = []

    ContentItem.where(content_id: nil, publishing_app: "hmrc-manuals-api").each do |item|
      item.set(content_id: UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, item.base_path))
      content_items << "#{item.content_id},#{item.base_path}"
    end

    report_path = "./tmp/generated_hmrc_manuals_api_content_ids.txt"
    report_missing_content_ids(report_path, content_items)
  end

  def self.down; end

private

  def self.report_missing_content_ids(path, items)
    report_to_file(path, "content_id,base_path", items)
    puts "#{items.size} missing content_id values assigned."
    puts "Details written to #{path}"
  end

  def self.report_to_file(path, headings, items)
    File.open(path, "w") do |file|
      file.puts headings
      file.puts items.join("\n")
    end
  end
end
