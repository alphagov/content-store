class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  NON_RENDERABLE_FORMATS = %w(redirect gone)

  def self.create_or_replace(base_path, details)
    result = :created
    result = :replaced if ContentItem.where(:base_path => base_path).exists?

    item = ContentItem.new(:base_path => base_path)
    item.assign_attributes(details)

    item.upsert or result = false
    return result, item
  rescue Mongoid::Errors::UnknownAttribute => e
    extra_fields = details.keys - self.fields.keys - %w(update_type)
    item.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    return false, item
  rescue Mongoid::Errors::InvalidValue => e
    item.errors.add(:base, e.message)
    return false, item
  end

  field :_id, :as => :base_path, :type => String
  field :content_id, :type => String
  field :title, :type => String
  field :description, :type => String
  field :format, :type => String
  field :locale, :type => String, :default => I18n.default_locale.to_s
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
  scope :renderable_content, -> { where(:format.nin => NON_RENDERABLE_FORMATS) }

  validates :base_path, absolute_path: true
  validates :content_id, uuid: true, allow_nil: true
  validates :format, :publishing_app, presence: true
  # This isn't persisted, but needs to be set when making changes because it's used in the message queue.
  validates :update_type, presence: { if: :changed? }
  validates :format, :update_type, format: { with: /\A[a-z0-9_]+\z/i, allow_blank: true }
  validates :title, presence: true, if: :renderable_content?
  validates :rendering_app, presence: true, format: /\A[a-z0-9-]*\z/,if: :renderable_content?
  validate :route_set_is_valid
  validate :links_are_valid
  validates :locale,
            inclusion: { in: I18n.available_locales.map(&:to_s),
                         message: 'must be a supported locale' },
            if: :renderable_content?

  # Saves and upserts trigger different sets of callbacks; to be safe, we need
  # to register for both
  before_save :register_routes
  before_upsert :register_routes

  # The updated_at field isn't set on upsert - https://github.com/mongoid/mongoid/issues/3716
  before_upsert :set_updated_at

  after_save :send_message
  after_upsert :send_message

  after_save :cleanup_publish_intent
  after_upsert :cleanup_publish_intent

  # We want to look up related items by their content ID, excluding those that
  # are redirects; when multiple items exist, we take the most recent one, and
  # we need its base_path and its title. By indexing all these fields, we can
  # get hold of these related items purely from the index, without having to go
  # and fetch the entire document.
  index({:content_id => 1, :locale => 1, :format => 1, :updated_at => -1, :title => 1, :_id => 1})

  # We want to force the JSON representation to use "base_path" instead of
  # "_id" to prevent "_id" being exposed outside of the model.
  def as_json(options = nil)
    super(options).tap do |hash|
      hash["base_path"] = hash.delete("_id")
    end
  end

  def redirect?
    self.format == "redirect"
  end

  def gone?
    self.format == "gone"
  end

  # Return a Hash of link types to lists of related items
  def linked_items
    items = {}
    links.each do |link_type, content_ids|
      items[link_type] = load_associated_content_items(content_ids)
    end
    items["available_translations"] = available_translations if available_translations.any?
    items
  end

private
  def available_translations
    @available_translations ||= load_available_translations
  end

  def load_available_translations
    ContentItem
      .excluding_redirects
      .where(:content_id => content_id)
      .only(:locale, :base_path, :title)
      .sort(:locale => 1, :updated_at => 1)
      .group_by(&:locale)
      .map { |locale, items| items.last }
  end

  def load_associated_content_items(content_ids)
    content_ids.map { |content_id|
      load_associated_content_item(content_id, self.locale)
    }.compact
  end

  def load_associated_content_item(content_id, preferred_locale)
    # This query is designed to be entirely covered by the index above
    candidate_items = ContentItem
      .excluding_redirects
      .where(:content_id => content_id)
      .where(:locale => {"$in" => [I18n.default_locale.to_s, preferred_locale]})
      .only(:locale, :base_path, :title)
      .sort(:updated_at => 1)

    candidate_items.select { |i| i.locale == preferred_locale }.last ||
      candidate_items.select { |i| i.locale == I18n.default_locale.to_s }.last
  end

  def registerable_route_set
    @registerable_route_set ||= RegisterableRouteSet.from_content_item(self)
  end

  def route_set_is_valid
    unless base_path.present? && registerable_route_set.valid?
      errors.set(:routes, registerable_route_set.errors[:registerable_routes])
      errors.set(:redirects, registerable_route_set.errors[:registerable_redirects])
    end
  end

  def link_key_is_valid?(link_key)
    link_key.is_a?(String) &&
      link_key =~ /\A[a-z0-9_]+\z/ &&
      link_key != 'available_translations'
  end

  def links_are_valid
    # Test that the `links` attribute, if set, is a hash from strings to lists
    # of UUIDs
    return if links.empty?

    bad_keys = links.keys.reject { |key| link_key_is_valid?(key) }
    unless bad_keys.empty?
      errors[:links] = "Invalid link types: #{bad_keys.to_sentence}"
    end

    bad_values = links.values.reject { |value|
      value.is_a?(Array) && value.all? { |content_id|
        UUIDValidator::UUID_PATTERN.match(content_id)
      }
    }
    unless bad_values.empty?
      errors[:links] = "must map to lists of UUIDs"
    end
  end

  def register_routes
    registerable_route_set.register! unless self.format.start_with?("placeholder")
  end

  def send_message
    Rails.application.queue_publisher.send_message(self)
  end

  def renderable_content?
    !NON_RENDERABLE_FORMATS.include?(format)
  end

  def cleanup_publish_intent
    unless self.update_type == "republish"
      PublishIntent.destroy_all(:base_path => self.base_path)
    end
  end
end
