class RemoveNonCaseStudyWhitehallUnpublishings < Mongoid::Migration
  def self.up
    puts "Removing redirects for #{content_items.count} items"
    content_items.each do |content_item|
      if content_item.format == "redirect"
        remove_redirect(content_item)
      end
      content_item.destroy
      puts "Destroyed content item #{content_item.id}"
    end
    router_api.commit_routes
  end

  def self.down
    raise "non-reversible migration"
  end

  def self.remove_redirect(content_item)
    content_item.redirects.each do |redirect|
      begin
        router_api.delete_route(redirect["path"], redirect["type"])
        puts "  Removed redirect '#{redirect['path']}'"
      rescue GdsApi::HTTPNotFound => e
        puts "  Redirect #{redirect['path']} not found. Nothing done."
      end
    end
  end

  def self.content_items
    ContentItem.where(
      base_path: { "$in" => all_paths },
      publishing_app: "whitehall",
      format: { "$in" => %w[unpublishing redirect] },
    )
  end

  def self.router_api
    Rails.application.router_api
  end

  def self.all_paths
    File.readlines(File.dirname(__FILE__) + "/20141219114603_unpublished_editions.txt")
      .map(&:strip)
      .reject(&:empty?)
  end
end
