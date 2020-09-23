namespace :data_hygiene do
  desc "Find policies that redirect to somewhere, but don't have the correct content item set up"
  task inconstent_policy_redirects: :environment do
    content_items = ContentItem.where(format: "placeholder", publishing_app: "whitehall", base_path: /^\/government\/policies/)

    puts "Analyzing #{content_items.count} content items"

    with_wrong_redirects = InconsistentRedirectFinder.new(content_items).items_with_inconsistent_redirects

    puts "Found #{with_wrong_redirects.count} content items that redirect but aren't of format 'redirect'"

    with_wrong_redirects.each do |content_item|
      route = Rails.application.router_api.get_route(content_item.base_path)
      puts [content_item.base_path, route.redirect_to].join(",")
    end
  end
end
