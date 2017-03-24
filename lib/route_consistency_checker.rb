require "set"

require "gds_api/router"

class RouteConsistencyChecker
  attr_reader :errors

  def initialize(routes, router_data)
    @routes = load_routes(routes)
    @remaining_routes = Set.new(@routes.keys)
    @errors = Hash.new { |hash, key| hash[key] = [] }
    @router_data = load_router_data(router_data)
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
    @remaining_routes.each do |path|
      next if @router_data.include?(path)

      route = @routes.fetch(path)
      next if route["disabled"]
      next if route["handler"] == "gone"
      next if route["handler"] == "redirect" && !route["backend_id"].present?

      content_item = ContentItem.find_by_path(route["incoming_path"])
      next if content_item

      @errors[route["incoming_path"]] << "No content item available."
    end
  end

private

  def content_items_to_check
    ContentItem
      .where(:content_id.nin => ["", nil])
      .where(:schema_name.not => /^placeholder/)
  end

  def load_routes(filename)
    routes = {}

    Zlib::GzipReader.open(filename) do |file|
      csv = CSV.new(file)
      keys = csv.gets
      csv.each do |row|
        route = Hash[keys.zip(row)]
        route["disabled"] = route["disabled"] == "true"
        route["updated_at"] = Time.parse(route["updated_at"])
        incoming_path = route.fetch("incoming_path")
        routes[incoming_path.to_sym] = route
      end
    end

    routes
  end

  def load_router_data(path)
    routes = Set.new

    Dir.glob(path + "/data/*.csv").each do |csv_path|
      CSV.foreach(csv_path) do |row|
        routes.add?(row[0].to_sym)
      end
    end

    routes
  end

  def get_route(path)
    begin
      route = @routes.fetch(path.to_sym)
      @remaining_routes.delete?(path.to_sym)
      route
    rescue KeyError
      @errors[path] << "Path (#{path}) was not found!"
      nil
    end
  end

  def check_redirect(content_item, redirect)
    path = redirect[:path]

    res = get_route(path)
    return unless res

    return if content_item.updated_at > res["updated_at"]

    if res["handler"] != "redirect"
      @errors[content_item.base_path] << "Handler is not a redirect for " \
                                         "#{path}."
    end

    if res["redirect_to"] != redirect[:destination]
      @errors[content_item.base_path] << "Route destination " \
                                         "(#{res['redirect_to']}) does not " \
                                         "match item destination " \
                                         "(#{redirect['destination']})."
    end
  end

  def check_route(content_item, route)
    path = route[:path]

    res = get_route(path)
    return unless res

    return if content_item.updated_at > res["updated_at"]

    if res["handler"] != expected_handler(content_item)
      @errors[content_item.base_path] << "Handler (#{res['handler']}) does " \
                                         "not match expected item handler " \
                                         "(#{expected_handler(content_item)})."
    end

    if res["backend_id"] != content_item.rendering_app
      @errors[content_item.base_path] << "Backend ID (#{res['backend_id']}) " \
                                         "does not match item rendering app " \
                                         "(#{content_item.rendering_app})."
    end

    @errors[content_item.base_path] << "Route is marked as disabled." if res["disabled"]
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
