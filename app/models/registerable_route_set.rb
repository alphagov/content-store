class RegisterableRouteSet < Struct.new(:registerable_routes, :base_path, :rendering_app)
  include ActiveModel::Validations

  validate :registerable_routes_validate,
           :base_path_is_a_registerable_route,
           :routes_are_beneath_base_path

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

  def route_paths
    registerable_routes.map(&:path)
  end

  def registerable_routes_validate
    unless registerable_routes.all?(&:valid?)
      errors[:base] << "are invalid"
    end
  end

  def base_path_is_a_registerable_route
    unless route_paths.include?(base_path)
      errors[:base] << 'must include the base_path'
    end
  end

  def routes_are_beneath_base_path
    unless route_paths.all? {|path| path.starts_with?(base_path) }
      errors[:base] << 'must be below the base path'
    end
  end
end
