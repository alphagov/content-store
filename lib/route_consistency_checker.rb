require "set"
require "gds_api/router"

class RouteConsistencyChecker
  attr_reader :errors

  def initialize(routes, router_data)
    @routes = routes
    @router_data = router_data
    @checked_routes = Set.new
    @errors = Hash.new { |hash, key| hash[key] = [] }
  end

  def check_content
    content_items_to_check.each do |content_item|
      content_item.redirects.each do |redirect|
        check_redirect(content_item, redirect)
      end

      content_item.routes.each do |route|
        check_route(content_item, route)
      end
    end
  end

  def check_routes
    unchecked_routes.each do |path|
      next if router_data.include?(path)

      route = routes.fetch(path)
      next unless is_valid_route?(route)

      content_item = find_content_item(route.incoming_path)

      errors[route.incoming_path] << "No content item available." unless content_item
    end
  end

private

  attr_reader :routes, :router_data, :checked_routes

  def content_items_to_check
    ContentItem
      .where(:content_id.nin => ["", nil])
      .where(:schema_name.not => /^placeholder/)
  end

  def unchecked_routes
    Set.new(routes.keys) - checked_routes
  end

  def is_valid_route?(route)
    !route.disabled && route.handler != "gone" && !(route.handler == "redirect" && route.backend_id.blank?)
  end

  def get_route(path)
    route = routes.fetch(path.to_sym)
    checked_routes.add?(path.to_sym)
    route
  rescue KeyError
    errors[path] << "Path (#{path}) was not found!"
    nil
  end

  def first_item_or_nil(items, kind)
    if items.length > 1
      errors[path] << "Multiple content items returned for #{kind}."
      return nil
    end
    items.first
  end

  def find_content_item_by_route(path)
    items = ContentItem.where("routes" => path).entries
    first_item_or_nil(items, "route")
  end

  def find_content_item_by_redirect(path)
    items = ContentItem.where("redirects" => path).entries
    first_item_or_nil(items, "redirect")
  end

  def find_content_item(path)
    # We cannot use an 'or' query here as it seems to be slower than doing this
    # irb(main):019:0> time { ContentItem.where(routes: { "$elemMatch" => { path: path } }).first }
    #   0.000000   0.000000   0.000000 (  0.006512)
    # irb(main):020:0> time { ContentItem.where(redirects: { "$elemMatch" => { path: path } }).first }
    #   0.010000   0.000000   0.010000 (  0.004688)
    # irb(main):021:0> time { ContentItem.or({ redirects: { "$elemMatch" => { path: path } } }, { routes: { "$elemMatch" => { path: path } } }).first }
    #   0.000000   0.000000   0.000000 ( 11.314430)
    find_content_item_by_route(path) || find_content_item_by_redirect(path)
  end

  def check_redirect(content_item, redirect)
    path = redirect[:path]

    result = get_route(path)

    return if !result || content_item.updated_at > result.updated_at

    if result.handler != "redirect"
      errors[path] << "Handler should be a redirect."
    end

    if result.redirect_to != redirect[:destination]
      errors[path] << "Route destination (#{result.redirect_to}) does not " \
                      "match item destination (#{redirect[:destination]})."
    end
  end

  def check_route(content_item, route)
    path = route[:path]

    result = get_route(path)

    return if !result || content_item.updated_at > result.updated_at

    if result.handler != expected_handler(content_item)
      errors[path] << "Handler (#{result.handler}) does not match expected " \
                      "item handler (#{expected_handler(content_item)})."
    end

    if should_check_backend_id(result)
      if result.backend_id != content_item.rendering_app
        errors[path] << "Backend ID (#{result.backend_id}) does not match " \
                        "item rendering app (#{content_item.rendering_app})."
      end
    end

    errors[path] << "Route is marked as disabled." if result.disabled
  end

  def should_check_backend_id(route)
    route.handler == "backend" || route.backend_id.present?
  end

  def expected_handler(content_item)
    if content_item.gone?
      "gone"
    elsif content_item.redirect?
      "redirect"
    else
      "backend"
    end
  end
end
