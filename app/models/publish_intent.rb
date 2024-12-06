class PublishIntent < ApplicationRecord
  validates_each :routes do |record, attr, value|
    # This wording replicates the original Mongoid error message - we don't know if any downstream
    # consumers rely on parsing error messages at the moment
    record.errors.add attr, "Value of type #{value.class} cannot be written to a field of type Array" unless value.nil? || value.respond_to?(:each)
  end

  def self.create_or_update(base_path, attributes)
    intent = PublishIntent.find_or_initialize_by(base_path:)
    result = intent.new_record? ? :created : :replaced

    intent.assign_attributes(attributes)
    result = false unless intent.save!
    [result, intent]
  rescue ActiveRecord::UnknownAttributeError
    extra_fields = attributes.keys - attribute_names
    intent.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    [false, intent]
  rescue ActiveRecord::RecordInvalid => e
    intent.errors.add(:base, e.message)
    [false, intent]
  end

  def self.find_by_path(path)
    ::FindByPath.new(self).find(path)
  end

  PUBLISH_TIME_LEEWAY = 5.minutes

  validates :base_path, absolute_path: true
  validates :publish_time, presence: true
  validates :rendering_app, presence: true, format: /\A[a-z0-9-]*\z/

  after_save :register_routes

  def as_json(options = nil)
    super(options).tap do |hash|
      hash["errors"] = errors.as_json.stringify_keys if errors.any?
    end
  end

  def past?
    publish_time <= PUBLISH_TIME_LEEWAY.ago
  end

  def content_item
    ContentItem.where(base_path:).first
  end

  # Called nightly from a cron job
  def self.cleanup_expired
    where("publish_time < ?", PUBLISH_TIME_LEEWAY.ago).delete_all
  end

  def base_path_without_root
    base_path&.sub(%r{^/}, "")
  end

private

  def route_set
    @route_set ||= RouteSet.from_publish_intent(self)
  end

  def register_routes
    route_set.register!
  end
end
