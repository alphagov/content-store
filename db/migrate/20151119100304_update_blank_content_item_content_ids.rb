require "uuidtools"

class UpdateBlankContentItemContentIds < Mongoid::Migration
  def self.up
    content_items = []

    ContentItem.where(content_id: nil, publishing_app: "hmrc-manuals-api").each do |item|
      item.set(content_id: UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, item.base_path))
      content_items << "#{item.content_id},#{item.publishing_app},#{item.base_path}"
    end

    report_path = "./tmp/generated_hmrc_manuals_api_content_ids.txt"
    report_missing_content_ids(report_path, content_items)

    content_items = []

    ContentItem.where(content_id: nil).each do |item|
      item.set(content_id: SecureRandom.uuid)
      content_items << "#{item.content_id},#{item.publishing_app},#{item.base_path}"
    end

    report_path = "./tmp/generated_content_ids.txt"
    report_missing_content_ids(report_path, content_items)

    content_items = []

    ContentItem.renderable_content.where(public_updated_at: nil).each do |item|
      item.set(public_updated_at: item.updated_at)
      content_items << "#{item.public_updated_at},#{item.publishing_app},#{item.base_path}"
    end

    report_path = "./tmp/assigned_public_updated_at.txt"
    report_to_file(report_path, "public_updated_at,publishing_app,base_path", content_items)
    puts "#{content_items.size} missing public_updated_at values assigned."
    puts "Details written to #{report_path}"
  end

  def self.down
  end

private

  def self.report_missing_content_ids(path, items)
    report_to_file(path, "content_id,publishing_app,base_path", items)
    puts "#{items.size} missing content_id values assigned."
    puts "Details written to #{path}"
  end

  def self.report_to_file(path, headings, items)
    File.write(path, headings)
    File.write(path, items.join("\n"))
  end
end
