class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :_id, :as => :base_path, :type => String
  field :title, :type => String
  field :description, :type => String
  field :format, :type => String
  field :need_ids, :type => Array, :default => []
  field :public_updated_at, :type => DateTime
  field :details, :type => Hash, :default => {}
  field :rendering_app, :type => String
  field :registered_routes, :type => Array, :default => []

  PUBLIC_ATTRIBUTES = %w(base_path title description format need_ids updated_at public_updated_at details).freeze

  validates :base_path, uniqueness: true, absolute_path: true
  validates :title, :format, :rendering_app, presence: true
  validate :route_set_is_valid

  before_save :register_and_store_routes

  # Setter for defining routes to the content item.
  #
  # +routes_attrs+ should be an array of hashes containing both a 'path' and a
  # 'type' key. 'path' defines the absolute URL path to the content and 'type'
  # is either 'exact' or 'prefix', depending on the type of route. For example:
  #
  #   [ { 'path' => '/content', 'type' => 'exact' },
  #     { 'path' => '/content.json', 'type' => 'exact' },
  #     { 'path' => '/content/subpath', 'type' => 'prefix' } ]
  #
  # All paths must be below the +base_path+ and +base_path+  must be defined as
  # a route here for the routes to be valid.  The specified routes will be
  # registered with the router when the content item is saved.
  def routes=(routes_attrs)
    @registerable_route_set = initialise_registerable_route_set(routes_attrs)
  end

  # Array of +RegisterableRoutes+ currently set for this content item
  def registerable_routes
    registerable_route_set.registerable_routes
  end

  def as_json(options = nil)
    super(options).slice(*PUBLIC_ATTRIBUTES).tap do |hash|
      hash["base_path"] = self.base_path
      hash["errors"] = self.errors.as_json.stringify_keys if self.errors.any?
    end
  end

private

  def registerable_route_set
    @registerable_route_set ||= initialise_registerable_route_set(registered_routes)
  end

  def initialise_registerable_route_set(routes_attrs)
    RegisterableRouteSet.from_route_attributes(routes_attrs, base_path, rendering_app)
  end

  def route_set_is_valid
    unless base_path.present? && registerable_route_set.valid?
      errors[:routes] += registerable_route_set.errors.full_messages
    end
  end

  def register_and_store_routes
    registerable_route_set.register!
    self.registered_routes = registerable_routes.map { |r| { 'path' => r.path, 'type' => r.type } }
  end
end
