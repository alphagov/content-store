class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  NON_RENDERABLE_FORMATS = %w(redirect gone)

  def self.create_or_replace(base_path, attributes)
    previous_item = ContentItem.where(:base_path => base_path).first
    result = previous_item ? :replaced : :created

    item = ContentItem.new(:base_path => base_path)
    item.assign_attributes(attributes)

    if item.upsert
      item.register_routes(previous_item: previous_item)
    else
      result = false
    end
    return result, item
  rescue Mongoid::Errors::UnknownAttribute => e
    extra_fields = attributes.keys - self.fields.keys - %w(update_type)
    item.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    return false, item
  rescue Mongoid::Errors::InvalidValue => e
    item.errors.add(:base, e.message)
    return false, item
  end

  field :_id, :as => :base_path, :type => String, :overwrite => true
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
  field :access_limited, :type => Hash, :default => {}
  field :phase, :type => String
  attr_accessor :update_type

  scope :renderable_content, -> { where(:format.nin => NON_RENDERABLE_FORMATS) }

  validates :base_path, absolute_path: true
  validates :content_id, uuid: true, allow_nil: true
  validates :format, :publishing_app, presence: true
  validates :format, :update_type, format: { with: /\A[a-z0-9_]+\z/i, allow_blank: true }
  validates :title, presence: true, if: :renderable_content?
  validates :rendering_app, presence: true, format: /\A[a-z0-9-]*\z/,if: :renderable_content?
  validates :public_updated_at, presence: true, if: :renderable_content?
  validate :route_set_is_valid
  validate :no_extra_route_keys
  validate :links_are_valid
  validate :access_limited_is_valid
  validates :phase,
            inclusion: { in: ['alpha', 'beta'],
                         allow_nil: true,
                         message: 'must be either alpha, beta, or nil' }
  validates :locale,
            inclusion: { in: I18n.available_locales.map(&:to_s),
                         message: 'must be a supported locale' },
            if: :renderable_content?

  # The updated_at field isn't set on upsert - https://jira.mongodb.org/browse/MONGOID-3716
  before_upsert :set_updated_at

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
    items = load_linked_items
    items["available_translations"] = available_translations if available_translations.any?
    items
  end

  def viewable_by?(user_uid)
    !access_limited? || authorised_user_uids.include?(user_uid)
  end

  def register_routes(previous_item: nil)
    return if self.format.start_with?("placeholder")
    return if previous_item && previous_item.registerable_route_set == self.registerable_route_set
    self.registerable_route_set.register!
  end

protected

  def registerable_route_set
    @registerable_route_set ||= RegisterableRouteSet.from_content_item(self)
  end

private

  def authorised_user_uids
    access_limited['users']
  end

  def load_linked_items
    # For each linked content_id find all non-redirect content items with
    # matching content_id in either this item's locale, or the default locale
    # with the most recently updated first.
    potential_items_by_id = ContentItem
      .renderable_content
      .where(:content_id => {"$in" => links.values.flatten.uniq})
      .where(:locale => {"$in" => [I18n.default_locale.to_s, self.locale].uniq})
      .only(:content_id, :locale, :base_path, :title, :description)
      .sort(:updated_at => -1)
      .group_by(&:content_id)

    # For each set of items for a given content_id, pick the first one that
    # matches this item's locale, or fall back to the first one matching the
    # default locale.
    required_items = potential_items_by_id.each_with_object({}) do |(content_id, items), results|
      results[content_id] = items.find {|i| i.locale == self.locale } || items.find {|i| i.locale == I18n.default_locale.to_s }
    end

    # build up the links hash using the selected items above
    links.each_with_object({}) do |(link_type, content_ids), result|
      result[link_type] = content_ids.map {|id| required_items[id] }.compact
    end
  end

  def available_translations
    @available_translations ||= load_available_translations
  end

  def load_available_translations
    return [self] if self.content_id.blank?
    ContentItem
      .renderable_content
      .where(:content_id => content_id)
      .only(:locale, :base_path, :title, :description)
      .sort(:locale => 1, :updated_at => 1)
      .group_by(&:locale)
      .map { |locale, items| items.last }
  end

  def route_set_is_valid
    unless base_path.present? && registerable_route_set.valid?
      errors.set(:routes, registerable_route_set.errors[:registerable_routes])
      errors.set(:redirects, registerable_route_set.errors[:registerable_redirects])
    end
  end

  def access_limited_is_valid
    if access_limited? && (!access_limited_keys_valid? || !access_limited_values_valid?)
      errors.set(:access_limited, ['is not valid'])
    end
  end

  def access_limited_keys_valid?
    access_limited.keys == ['users']
  end

  def access_limited_values_valid?
    authorised_user_uids.is_a?(Array) && authorised_user_uids.all? { |id| id.is_a?(String) }
  end

  def no_extra_route_keys
    if routes.any? { |r| (r.keys - %w(path type)).any? }
      errors.add(:routes, "are invalid")
    end
    if redirects.any? { |r| (r.keys - %w(path type destination)).any? }
      errors.add(:redirects, "are invalid")
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
        UUIDValidator.valid?(content_id)
      }
    }
    unless bad_values.empty?
      errors[:links] = "must map to lists of UUIDs"
    end
  end

  def renderable_content?
    !NON_RENDERABLE_FORMATS.include?(format)
  end
end
