class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  def self.create_or_replace(base_path, details)
    result = :created
    result = :replaced if ContentItem.where(:base_path => base_path).exists?

    item = ContentItem.new(:base_path => base_path)
    item.assign_attributes(details)

    item.upsert or result = false
    return result, item
  rescue Mongoid::Errors::UnknownAttribute => e
    extra_fields = details.keys - self.fields.keys - %w(update_type)
    item.errors.add(:base, "unrecognised field(s) #{extra_fields.join(',')} in input")
    return false, item
  end

  field :_id, :as => :base_path, :type => String
  field :title, :type => String
  field :description, :type => String
  field :format, :type => String
  field :need_ids, :type => Array, :default => []
  field :public_updated_at, :type => DateTime
  field :details, :type => Hash, :default => {}
  field :publishing_app, :type => String
  field :rendering_app, :type => String
  field :routes, :type => Array, :default => []
  field :redirects, :type => Array, :default => []
  attr_accessor :update_type

  PUBLIC_ATTRIBUTES = %w(base_path title description format need_ids updated_at public_updated_at details).freeze

  validates :base_path, absolute_path: true
  validates :format, presence: true
  # This isn't persisted, but needs to be set when making changes because it's used in the message queue.
  validates :update_type, presence: { if: :changed? }
  validates :format, :update_type, format: { with: /\A[a-z0-9_-]+\z/i, allow_blank: true }
  validates :title, :rendering_app, presence: true, unless: :redirect?
  validate :route_set_is_valid

  # Saves and upserts trigger different sets of callbacks; to be safe, we need
  # to register for both
  before_save :register_routes
  before_upsert :register_routes

  # The updated_at field isn't set on upsert - https://github.com/mongoid/mongoid/issues/3716
  before_upsert :set_updated_at

  after_save :send_message
  after_upsert :send_message

  def as_json(options = nil)
    super(options).slice(*PUBLIC_ATTRIBUTES).tap do |hash|
      hash["base_path"] = self.base_path
      hash["errors"] = self.errors.as_json.stringify_keys if self.errors.any?
    end
  end

  def redirect?
    self.format == "redirect"
  end

private

  def registerable_route_set
    @registerable_route_set ||= RegisterableRouteSet.from_content_item(self)
  end

  def route_set_is_valid
    unless base_path.present? && registerable_route_set.valid?
      errors[:routes] += registerable_route_set.errors[:registerable_routes]
      errors[:redirects] += registerable_route_set.errors[:registerable_redirects]
    end
  end

  def register_routes
    registerable_route_set.register!
  end

  def send_message
    Rails.application.queue_publisher.send_message(self)
  end
end
