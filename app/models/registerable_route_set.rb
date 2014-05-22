class RegisterableRouteSet < Struct.new(:registerable_routes, :base_path, :rendering_app)
  include ActiveModel::Validations

  validate :registerable_routes_are_valid,
           :registerable_routes_include_base_path,
           :all_routes_are_beneath_base_path

  def self.from_route_attributes(route_attributes, base_path, rendering_app)
    registerable_routes = route_attributes.map do |attrs|
      RegisterableRoute.new(attrs['path'], attrs['type'], rendering_app)
    end

    new(registerable_routes, base_path, rendering_app)
  end

  def register!
    registerable_routes.each { |route| register_route(route) }
    commit_routes
  end

private

  def register_route(route)
    Rails.application.router_api.add_route(route.path, route.type, rendering_app, skip_commit: true)
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
