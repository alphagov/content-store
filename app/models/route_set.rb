class RouteSet < OpenStruct
  def initialize(hash = nil)
    super
    self.routes ||= []
    self.gone_routes ||= []
    self.redirects ||= []
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
      gone_routes = item.routes.map(&:deep_symbolize_keys)
    else
      routes = item.routes.map(&:deep_symbolize_keys)
    end

    redirects = item.redirects.map(&:deep_symbolize_keys)

    new(
      routes: routes,
      gone_routes: gone_routes,
      redirects: redirects,
      base_path: item.base_path,
      rendering_app: item.router_rendering_app,
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
    if (item = intent.content_item)
      # if a content item exists we only want to register the set of routes
      # that don't already exist on the item
      route_attrs -= item.routes
    end
    route_set.routes = route_attrs.map(&:deep_symbolize_keys)
    route_set
  end

  def register!
    return unless any_routes?

    if is_redirect
      redirects.each do |route|
        register_redirect(route)
      end
    elsif is_gone
      gone_routes.each do |route|
        register_gone_route(route)
      end
    else
      register_rendering_app

      routes.each do |route|
        register_route(route, rendering_app)
      end

      redirects.each do |route|
        register_redirect(route)
      end
    end

    commit_routes
  end

  def delete!
    return unless any_routes?

    paths.each do |path|
      begin
        router_api.delete_route(path)
      rescue GdsApi::HTTPNotFound
        # Ignore this, as this path could have already been deleted
        next
      end
    end

    commit_routes
  end

private

  def register_rendering_app
    router_api.add_backend(rendering_app, Plek.find(rendering_app) + "/")
  end

  def register_redirect(route)
    router_api.add_redirect_route(
      route.fetch(:path),
      route.fetch(:type),
      route.fetch(:destination),
      route.fetch(:redirect_type, "permanent"),
      segments_mode: route[:segments_mode],
    )
  end

  def register_gone_route(route)
    router_api.add_gone_route(
      route.fetch(:path),
      route.fetch(:type),
    )
  end

  def register_route(route, rendering_app)
    router_api.add_route(
      route.fetch(:path),
      route.fetch(:type),
      rendering_app,
    )
  end

  def commit_routes
    router_api.commit_routes
  end

  def router_api
    Rails.application.router_api
  end

  def paths
    (routes + gone_routes + redirects).map do |hash|
      hash[:path]
    end
  end

  def any_routes?
    routes.any? || gone_routes.any? || redirects.any?
  end
end
