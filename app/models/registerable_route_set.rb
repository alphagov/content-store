class RegisterableRouteSet < OpenStruct
  def initialize(hash = nil)
    super
    self.registerable_routes ||= []
    self.registerable_gone_routes ||= []
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
    if item.gone?
      registerable_gone_routes = item.routes.map(&:deep_symbolize_keys)
    else
      registerable_routes = item.routes.map(&:deep_symbolize_keys)
    end

    registerable_redirects = item.redirects.map(&:deep_symbolize_keys)

    new(
      registerable_routes: registerable_routes,
      registerable_gone_routes: registerable_gone_routes,
      registerable_redirects: registerable_redirects,
      base_path: item.base_path,
      rendering_app: item.rendering_app,
      is_redirect: item.redirect?,
      is_gone: item.gone?,
    )
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
    end
    route_set.registerable_routes = route_attrs.map(&:deep_symbolize_keys)
    route_set
  end

  def register!
    return unless any_routes?

    if is_redirect
      registerable_redirects.each do |route|
        register_redirect(route)
      end
    elsif is_gone
      registerable_gone_routes.each do |route|
        register_gone_route(route)
      end
    else
      register_rendering_app

      registerable_routes.each do |route|
        register_route(route, rendering_app)
      end

      registerable_redirects.each do |route|
        register_redirect(route)
      end
    end

    commit_routes
  end

private

  def register_rendering_app
    Rails.application.router_api.add_backend(rendering_app, Plek.find(rendering_app, :force_http => true) + "/")
  end

  def register_redirect(route)
    Rails.application.router_api.add_redirect_route(
      route.fetch(:path),
      route.fetch(:type),
      route.fetch(:destination),
    )
  end

  def register_gone_route(route)
    Rails.application.router_api.add_gone_route(
      route.fetch(:path),
      route.fetch(:type),
    )
  end

  def register_route(route, rendering_app)
    Rails.application.router_api.add_route(
      route.fetch(:path),
      route.fetch(:type),
      rendering_app,
    )
  end

  def commit_routes
    Rails.application.router_api.commit_routes
  end

  def any_routes?
    registerable_routes.any? || registerable_gone_routes.any?  || registerable_redirects.any?
  end
end
