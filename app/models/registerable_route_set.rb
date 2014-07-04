class RegisterableRouteSet < OpenStruct

  def initialize(hash = nil)
    super
    self.registerable_routes ||= []
    self.registerable_redirects ||= []
  end

  include ActiveModel::Validations

  validate :registerable_routes_and_redirects_are_valid,
           :all_routes_and_redirects_are_beneath_base_path,
           :redirect_cannot_have_routes
  validate :registerable_routes_include_base_path, :unless => :is_redirect
  validate :registerable_redirects_include_base_path, :if => :is_redirect

  # +item.routes+ should be an array of hashes containing both a 'path' and a
  # 'type' key. 'path' defines the absolute URL path to the content and 'type'
  # is either 'exact' or 'prefix', depending on the type of route. For example:
  #
  #   [ { 'path' => '/content', 'type' => 'exact' },
  #     { 'path' => '/content.json', 'type' => 'exact' },
  #     { 'path' => '/content/subpath', 'type' => 'prefix' } ]
  #
  # All paths must be below the +base_path+ and +base_path+  must be defined as
  # a route for the routes to be valid.
  def self.from_content_item(item)
    registerable_routes = item.routes.map do |attrs|
      RegisterableRoute.new(:path => attrs['path'], :type => attrs['type'], :rendering_app => item.rendering_app)
    end

    new({
      :registerable_routes => registerable_routes,
      :base_path => item.base_path,
      :rendering_app => item.rendering_app,
    })
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

  def registerable_routes_and_redirects_are_valid
    unless registerable_routes.all?(&:valid?)
      errors[:base] << "are invalid"
    end
    unless registerable_redirects.all?(&:valid?)
      errors[:base] << "are invalid"
    end
  end

  def registerable_routes_include_base_path
    route_paths = registerable_routes.map(&:path)
    unless route_paths.include?(base_path)
      errors[:base] << 'must include the base_path'
    end
  end

  def registerable_redirects_include_base_path
    paths = registerable_redirects.map(&:path)
    unless paths.include?(base_path)
      errors[:base] << 'must include the base_path'
    end
  end

  def all_routes_and_redirects_are_beneath_base_path
    unless registerable_routes.all? {|route| base_path_with_extension?(route) || beneath_base_path?(route) }
      errors[:base] << 'must be below the base path'
    end
    unless registerable_redirects.all? {|redirect| base_path_with_extension?(redirect) || beneath_base_path?(redirect) }
      errors[:base] << 'must be below the base path'
    end
  end

  def redirect_cannot_have_routes
    if self.is_redirect && self.registerable_routes.any?
      errors[:base] << 'redirect items cannot have routes'
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
