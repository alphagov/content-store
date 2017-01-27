require 'gds_api/router'

class ContentConsistencyChecker
  attr_reader :base_path

  def initialize(base_path)
    @base_path = base_path
    @errors = []
  end

  def call
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

  def get_route(path)
    begin
      JSON.parse(router_api.get_route(path).raw_response_body)
    rescue GdsApi::HTTPNotFound
      @errors << "Path (#{path}) was not found!"
      nil
    end
  end

  def check_redirect(redirect)
    path = redirect[:path]

    res = get_route(path)
    return unless res

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
    @content_item ||= ContentItem.find_by!(base_path: base_path)
  rescue Mongoid::Errors::DocumentNotFound
    @errors << "Content (#{base_path}) could not be found."
    @content_item ||= nil
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
