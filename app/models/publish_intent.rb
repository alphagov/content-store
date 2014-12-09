class PublishIntent
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.create_or_update(base_path, details)
    intent = PublishIntent.find_or_initialize_by(:base_path => base_path)
    result = intent.new_record? ? :created : :replaced

    intent.update_attributes(details) or result = false
    return result, intent
  rescue Mongoid::Errors::UnknownAttribute => e
    extra_fields = details.keys - self.fields.keys
    intent.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    return false, intent
  rescue Mongoid::Errors::InvalidValue => e
    intent.errors.add(:base, e.message)
    return false, intent
  end

  PUBLISH_TIME_LEEWAY = 1.minute

  field :_id, :as => :base_path, :type => String
  field :publish_time, :type => DateTime
  field :publishing_app, :type => String
  field :rendering_app, :type => String
  field :routes, :type => Array, :default => []

  validates :base_path, :absolute_path => true
  validates :publish_time, :presence => true
  validates :rendering_app, :presence => true, :format => /\A[a-z0-9-]*\z/
  validate :route_set_is_valid

  def as_json(options = nil)
    super(options).tap do |hash|
      hash["base_path"] = hash.delete("_id")
      hash["errors"] = self.errors.as_json.stringify_keys if self.errors.any?
    end
  end

  def past?
    publish_time <= PUBLISH_TIME_LEEWAY.ago
  end

  # Called nightly from a cron job
  def self.cleanup_expired
    where(:publish_time.lt => PUBLISH_TIME_LEEWAY.ago).delete_all
  end

  private

  def registerable_route_set
    @registerable_route_set ||= RegisterableRouteSet.from_publish_intent(self)
  end

  def route_set_is_valid
    unless base_path.present? && registerable_route_set.valid?
      errors.set(:routes, registerable_route_set.errors[:registerable_routes])
    end
  end
end
