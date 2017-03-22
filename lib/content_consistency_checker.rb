require 'gds_api/router'

class ContentConsistencyChecker
  def initialize(routes)
    @routes = load_routes(routes)
  end

  def check_content(base_path)
    @base_path = base_path
    @errors = []

    return @errors unless content_item

    redirects.each do |redirect|
      check_redirect(redirect)
    end

    routes.each do |route|
      check_route(route)
    end

    @errors
  end

private
  attr_reader :base_path

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
        routes[incoming_path] = route
      end
    end

    routes
  end

  def get_route(path)
    begin
      @routes.fetch(path)
    rescue KeyError
      @errors << "Path (#{path}) was not found!"
      nil
    end
  end

  def check_redirect(redirect)
    path = redirect[:path]

    res = get_route(path)
    return unless res

    return if content_item.updated_at > res["updated_at"]

    if res["handler"] != "redirect"
      @errors << "router-api: Handler is not a redirect for #{path}."
    end

    if res["redirect_to"] != redirect[:destination]
      @errors << "router-api: Route destination (#{res['redirect_to']}) " \
                 "does not match item destination " \
                 "(#{redirect['destination']})."
    end
  end

  def check_route(route)
    path = route[:path]

    res = get_route(path)
    return unless res

    return if content_item.updated_at > res["updated_at"]

    if res["handler"] != expected_handler
      @errors << "Handler (#{res['handler']}) does not match expected item " \
                 "handler (#{expected_handler})."
    end

    if res["backend_id"] != rendering_app
      @errors << "Backend ID (#{res['backend_id']}) does not match item " \
                 "rendering app (#{rendering_app})."
    end

    @errors << "Route is marked as disabled." if res["disabled"]
  end

  def content_item
    ContentItem.find_by!(base_path: base_path)
  rescue Mongoid::Errors::DocumentNotFound
    @errors << "Content (#{base_path}) could not be found."
    nil
  end

  def expected_handler
    if content_item.gone?
      "gone"
    elsif content_item.redirect?
      "redirect"
    else
      "backend"
    end
  end

  def routes
    content_item.routes
  end

  def redirects
    content_item.redirects
  end

  def rendering_app
    content_item.rendering_app
  end

  def router_api
    Rails.application.router_api
  end
end
