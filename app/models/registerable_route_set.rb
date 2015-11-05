class RegisterableRouteSet < OpenStruct
  def initialize(hash = nil)
    super
    self.registerable_routes ||= []
    self.registerable_redirects ||= []
  end

  # +item.routes+ should be an array of hashes containing both a 'path' and a
  # 'type' key. 'path' defines the absolute URL path to the content and 'type'
  # is either 'exact' or 'prefix', depending on the type of route. For example:
  #
  #   [ { 'path' => '/content', 'type' => 'exact' },
  #     { 'path' => '/content.json', 'type' => 'exact' },
  #     { 'path' => '/content/subpath', 'type' => 'prefix' } ]
  #
  # +item.redirects+ should be an array of hashes containin a 'path', 'type' and
  # a 'destination' key.  'path' and 'type' are as above, 'destination' it the target
  # path for the redirect.
  #
  # All paths must be below the +base_path+ and +base_path+  must be defined as
  # a route for the routes to be valid.
  def self.from_content_item(item)
    registerable_routes = item.routes.map do |attrs|
      route_type = item.gone? ? RegisterableGoneRoute : RegisterableRoute
      route_type.new(attrs.slice("path", "type"))
    end
    registerable_redirects = item.redirects.map do |attrs|
      RegisterableRedirect.new(attrs.slice("path", "type", "destination"))
    end

    new({
      :registerable_routes => registerable_routes,
      :registerable_redirects => registerable_redirects,
      :base_path => item.base_path,
      :rendering_app => item.rendering_app,
      :is_redirect => item.redirect?,
      :is_gone => item.gone?,
    })
  end

  def self.from_publish_intent(intent)
    route_set = new(
      base_path: intent.base_path,
      rendering_app: intent.rendering_app,
    )
    route_attrs = intent.routes
    if item = intent.content_item
      # if a content item exists we only want to register the set of routes
      # that don't already exist on the item
      route_attrs -= item.routes
      route_set.is_supplimentary_set = true
    end
    route_set.registerable_routes = route_attrs.map do |attrs|
      RegisterableRoute.new(attrs.slice("path", "type"))
    end
    route_set
  end

  def register!
    return unless registerable_routes.any? || registerable_redirects.any?
    if is_redirect
      registerable_redirects.map(&:register!)
    elsif is_gone
      registerable_routes.map(&:register!)
    else
      register_rendering_app
      registerable_routes.each { |route| route.register!(rendering_app) }
      registerable_redirects.map(&:register!)
    end
    commit_routes
  end

private

  def register_rendering_app
    Rails.application.router_api.add_backend(rendering_app, Plek.find(rendering_app, :force_http => true) + "/")
  end

  def commit_routes
    Rails.application.router_api.commit_routes
  end
end
