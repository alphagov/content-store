class RegisterableRouteSet < Struct.new(:registerable_routes, :base_path, :rendering_app)
  include ActiveModel::Validations

  validate :registerable_routes_are_valid,
           :registerable_routes_include_base_path,
           :all_routes_are_beneath_base_path

  # +route_attributes+ should be an array of hashes containing both a 'path' and a
  # 'type' key. 'path' defines the absolute URL path to the content and 'type'
  # is either 'exact' or 'prefix', depending on the type of route. For example:
  #
  #   [ { 'path' => '/content', 'type' => 'exact' },
  #     { 'path' => '/content.json', 'type' => 'exact' },
  #     { 'path' => '/content/subpath', 'type' => 'prefix' } ]
  #
  # All paths must be below the +base_path+ and +base_path+  must be defined as
  # a route here for the routes to be valid.
  def self.from_route_attributes(route_attributes, base_path, rendering_app)
    registerable_routes = route_attributes.map do |attrs|
      RegisterableRoute.new(attrs['path'], attrs['type'], rendering_app)
    end

    new(registerable_routes, base_path, rendering_app)
  end

  def register!
    register_backend
    registerable_routes.each { |route| register_route(route) }
    commit_routes
  end

private

  def register_backend
    Rails.application.router_api.add_backend(rendering_app, Plek.new.find(rendering_app, :force_http => true) + "/")
  end

  def register_route(route)
    Rails.application.router_api.add_route(route.path, route.type, rendering_app)
  end

  def commit_routes
    Rails.application.router_api.commit_routes
  end

  def registerable_routes_are_valid
    unless registerable_routes.all?(&:valid?)
      errors[:base] << "are invalid"
    end
  end

  def registerable_routes_include_base_path
    route_paths = registerable_routes.map(&:path)

    unless route_paths.include?(base_path)
      errors[:base] << 'must include the base_path'
    end
  end

  def all_routes_are_beneath_base_path
    unless registerable_routes.all? {|route| base_path_with_extension?(route) || beneath_base_path?(route) }
      errors[:base] << 'must be below the base path'
    end
  end

  def base_path_with_extension?(route)
    route.path.match(%r(^#{base_path}\.\w+\z))
  end

  def beneath_base_path?(route)
    base_segments = segments_for(route.path)[0,base_path_segments.size]
    base_segments == base_path_segments
  end

  def base_path_segments
    @base_path_segments ||= segments_for(base_path)
  end

  def segments_for(path)
    path.split('/').reject(&:blank?)
  end
end
