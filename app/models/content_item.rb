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
  field :content_id, :type => String
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
  field :links, :type => Hash, :default => {}
  attr_accessor :update_type

  scope :excluding_redirects, ->{ where(:format.ne => "redirect") }

  validates :base_path, absolute_path: true
  validates :content_id, uuid: true, allow_nil: true
  validates :format, :publishing_app, presence: true
  # This isn't persisted, but needs to be set when making changes because it's used in the message queue.
  validates :update_type, presence: { if: :changed? }
  validates :format, :update_type, format: { with: /\A[a-z0-9_-]+\z/i, allow_blank: true }
  validates :title, :rendering_app, presence: true, unless: :redirect?
  validate :route_set_is_valid
  validate :links_are_valid

  # Saves and upserts trigger different sets of callbacks; to be safe, we need
  # to register for both
  before_save :register_routes
  before_upsert :register_routes

  # The updated_at field isn't set on upsert - https://github.com/mongoid/mongoid/issues/3716
  before_upsert :set_updated_at

  after_save :send_message
  after_upsert :send_message

  def as_json(options = nil)
    # We want to refer to this as `base_path` everywhere, rather than its
    # internal name of `_id`.
    super(options).tap do |hash|
      hash["base_path"] = hash.delete("_id")
    end
  end

  def redirect?
    self.format == "redirect"
  end

  # Return a Hash of link types to lists of related items
  def linked_items
    links.each_with_object({}) do |(link_type, content_ids), items|
      items[link_type] = content_ids.map { |content_id|
        ContentItem.excluding_redirects
                   .where(:content_id => content_id)
                   .sort(:updated_at => 1)
                   .last
      }.compact
    end
  end

private

  def registerable_route_set
    @registerable_route_set ||= RegisterableRouteSet.from_content_item(self)
  end

  def route_set_is_valid
    unless base_path.present? && registerable_route_set.valid?
      errors.set(:routes, registerable_route_set.errors[:registerable_routes])
      errors.set(:redirects, registerable_route_set.errors[:registerable_redirects])
    end
  end

  def links_are_valid
    # Test that the `links` attribute, if set, is a hash from strings to lists
    # of UUIDs
    return if links.empty?

    bad_keys = links.keys.reject { |key| key.is_a? String }
    if bad_keys.any?
      errors[:links] = "Invalid link types: #{bad_keys.to_sentence}"
    end

    bad_values = links.values.reject { |value|
      value.is_a?(Array) && value.all? { |content_id|
        UUIDValidator::UUID_PATTERN.match(content_id)
      }
    }

    if bad_values.any?
      errors[:links] = "must map to lists of UUIDs"
    end
  end

  def register_routes
    registerable_route_set.register! unless self.format == "placeholder"
  end

  def send_message
    Rails.application.queue_publisher.send_message(self)
  end
end
