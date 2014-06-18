class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :_id, :as => :base_path, :type => String
  field :title, :type => String
  field :description, :type => String
  field :format, :type => String
  field :need_ids, :type => Array, :default => []
  field :public_updated_at, :type => DateTime
  field :details, :type => Hash, :default => {}
  field :rendering_app, :type => String
  field :routes, :type => Array, :default => []

  PUBLIC_ATTRIBUTES = %w(base_path title description format need_ids updated_at public_updated_at details).freeze

  validates :base_path, absolute_path: true
  validates :title, :format, :rendering_app, presence: true
  validate :route_set_is_valid

  # Saves and upserts trigger different sets of callbacks; to be safe, we need
  # to register for both
  before_save :register_routes
  before_upsert :register_routes

  def as_json(options = nil)
    super(options).slice(*PUBLIC_ATTRIBUTES).tap do |hash|
      hash["base_path"] = self.base_path
      hash["errors"] = self.errors.as_json.stringify_keys if self.errors.any?
    end
  end

private

  def registerable_route_set
    @registerable_route_set ||= RegisterableRouteSet.from_route_attributes(routes, base_path, rendering_app)
  end

  def route_set_is_valid
    unless base_path.present? && registerable_route_set.valid?
      errors[:routes] += registerable_route_set.errors.full_messages
    end
  end

  def register_routes
    registerable_route_set.register!
  end
end
