class PublishIntent
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.create_or_update(base_path, attributes)
    intent = PublishIntent.find_or_initialize_by(base_path: base_path)
    result = intent.new_record? ? :created : :replaced

    result = false unless intent.update(attributes)
    [result, intent]
  rescue Mongoid::Errors::UnknownAttribute
    extra_fields = attributes.keys - fields.keys
    intent.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    [false, intent]
  rescue Mongoid::Errors::InvalidValue => e
    intent.errors.add(:base, e.message)
    [false, intent]
  end

  def self.find_by_path(path)
    ::FindByPath.new(self).find(path)
  end

  PUBLISH_TIME_LEEWAY = 5.minutes

  field :_id, as: :base_path, type: String, overwrite: true
  field :publish_time, type: DateTime
  field :publishing_app, type: String
  field :rendering_app, type: String
  field :routes, type: Array, default: []

  # We want to look up this model by route as well as the base_path
  index("routes.path" => 1, "routes.type" => 1)

  validates :base_path, absolute_path: true
  validates :publish_time, presence: true
  validates :rendering_app, presence: true, format: /\A[a-z0-9-]*\z/

  after_save :register_routes

  def as_json(options = nil)
    super(options).tap do |hash|
      hash["base_path"] = hash.delete("_id")
      hash["errors"] = errors.as_json.stringify_keys if errors.any?
    end
  end

  def past?
    publish_time <= PUBLISH_TIME_LEEWAY.ago
  end

  def content_item
    ContentItem.where(base_path: base_path).first
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
