class ReallyRemoveNonCaseStudyWhitehallUnpublishings < Mongoid::Migration
  def self.up
    puts "Removing redirects for #{content_items.count} items"
    content_items.each do |content_item|
      puts "Content item #{content_item.id}"
      if content_item.format == "redirect"
        remove_redirect(content_item)
      end
      content_item.destroy
      puts "  -> destroyed content item"
    end
    router_api.commit_routes
  rescue GdsApi::SocketErrorException
    puts "Router API is not available, skipping RemoveNonCaseStudyWhitehallUnpublishings"
  end

  def self.down
    raise "non-reversible migration"
  end

  def self.remove_redirect(content_item)
    content_item.redirects.each do |redirect|
      begin
        router_api.delete_route(redirect["path"], redirect["type"])
        puts "  -> removed redirect '#{redirect['path']}'"
      rescue GdsApi::HTTPNotFound, GdsApi::SocketErrorException => e
        puts "  -> redirect #{redirect['path']} not found. Nothing done."
      end
    end
  end

  def self.content_items
    ContentItem.where(
      publishing_app: "whitehall",
      format: { "$in" => %w[unpublishing redirect] },
    ).reject do |content_item|
      content_item.base_path =~ %r{/case-studies/}
    end
  end

  def self.router_api
    Rails.application.router_api
  end
end
