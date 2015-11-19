class UpdateBlankContentItemContentIds < Mongoid::Migration
  def self.up
    content_items = []

    ContentItem.where(content_id: nil).each do |item|
      item.update!(content_id: SecureRandom.uuid)

      content_items << "#{item.content_id},#{item.publishing_app},#{item.base_path}"
    end

    report_path = "./tmp/generated_content_ids.txt"
    File.write(report_path, "content_id,publishing_app,base_path")
    File.write(report_path, content_items.join("\n"))
    puts "#{content_items.size} missing content_id values assigned."
    puts "Details written to #{report_path}"

    content_items = []

    ContentItem.renderable_content.where(public_updated_at: nil).each do |item|
      item.update!(public_updated_at: item.updated_at)
      content_items << "#{item.public_updated_at},#{item.publishing_app},#{item.base_path}"
    end

    report_path = "./tmp/assigned_public_updated_at.txt"
    File.write(report_path, "public_updated_at,publishing_app,base_path")
    File.write(report_path, content_items.join("\n"))
    puts "#{content_items.size} missing public_updated_at values assigned."
    puts "Details written to #{report_path}"
  end

  def self.down
  end
end
