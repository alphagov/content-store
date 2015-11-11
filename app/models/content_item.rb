class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  NON_RENDERABLE_FORMATS = %w(redirect gone)

  def self.create_or_replace(base_path, attributes)
    previous_item = ContentItem.where(:base_path => base_path).first
    lock = UpdateLock.new(previous_item)

    transmitted_at = attributes["transmitted_at"]
    lock.check_availability!(transmitted_at)

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
    extra_fields = attributes.keys - self.fields.keys
    item.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    return false, item
  rescue Mongoid::Errors::InvalidValue => e
    item.errors.add(:base, e.message)
    return false, item
  rescue OutOfOrderTransmissionError => e
    return :stale
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
  field :phase, :type => String, :default => 'live'
  field :analytics_identifier, :type => String
  field :transmitted_at, :type => String

  scope :renderable_content, -> { where(:format.nin => NON_RENDERABLE_FORMATS) }

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
    return if previous_item && previous_item.route_set == self.route_set
    self.route_set.register!
  end

  def base_path_without_root
    base_path.sub(%r{^/}, "")
  end

protected

  def route_set
    @route_set ||= RouteSet.from_content_item(self)
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
      .only(:content_id, :locale, :base_path, :title, :description, :analytics_identifier)
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
    return [] if self.content_id.blank?
    ContentItem
      .renderable_content
      .where(:content_id => content_id)
      .only(:content_id, :locale, :base_path, :title, :description)
      .sort(:locale => 1, :updated_at => 1)
      .group_by(&:locale)
      .map { |locale, items| items.last }
  end
end
