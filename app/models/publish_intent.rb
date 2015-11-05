class PublishIntent
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.create_or_update(base_path, attributes)
    intent = PublishIntent.find_or_initialize_by(:base_path => base_path)
    result = intent.new_record? ? :created : :replaced

    intent.update_attributes(attributes) or result = false
    return result, intent
  rescue Mongoid::Errors::UnknownAttribute => e
    extra_fields = attributes.keys - self.fields.keys
    intent.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    return false, intent
  rescue Mongoid::Errors::InvalidValue => e
    intent.errors.add(:base, e.message)
    return false, intent
  end

  PUBLISH_TIME_LEEWAY = 1.minute

  field :_id, :as => :base_path, :type => String, :overwrite => true
  field :publish_time, :type => DateTime
  field :publishing_app, :type => String
  field :rendering_app, :type => String
  field :routes, :type => Array, :default => []

  validates :base_path, :absolute_path => true
  validates :publish_time, :presence => true
  validates :rendering_app, :presence => true, :format => /\A[a-z0-9-]*\z/

  after_save :register_routes

  def as_json(options = nil)
    super(options).tap do |hash|
      hash["base_path"] = hash.delete("_id")
      hash["errors"] = self.errors.as_json.stringify_keys if self.errors.any?
    end
  end

  def past?
    publish_time <= PUBLISH_TIME_LEEWAY.ago
  end

  def content_item
    ContentItem.where(:base_path => self.base_path).first
  end

  # Called nightly from a cron job
  def self.cleanup_expired
    where(:publish_time.lt => PUBLISH_TIME_LEEWAY.ago).delete_all
  end

  private

  def route_set
    @route_set ||= RouteSet.from_publish_intent(self)
  end

  def register_routes
    route_set.register!
  end
end
