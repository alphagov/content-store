class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  NON_RENDERABLE_FORMATS = %w(redirect gone)

  def self.create_or_replace(base_path, attributes)
    previous_item = ContentItem.where(base_path: base_path).first
    lock = UpdateLock.new(previous_item)

    lock.check_availability!(attributes)

    result = previous_item ? :replaced : :created

    item = ContentItem.new(base_path: base_path)
    item.assign_attributes(attributes)

    if item.upsert
      item.register_routes(previous_item: previous_item)
    else
      result = false
    end

    return result, item
  rescue Mongoid::Errors::UnknownAttribute
    extra_fields = attributes.keys - self.fields.keys
    item.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    return false, item
  rescue Mongoid::Errors::InvalidValue => e
    item.errors.add(:base, e.message)
    return false, item
  rescue OutOfOrderTransmissionError => e
    return :conflict, OpenStruct.new(
      errors: {
        type: "conflict",
        code: "409",
        message: e.message,
        fields: {
          transmitted_at: [e.message],
        }
      }
    )
  end

  field :_id, as: :base_path, type: String, overwrite: true
  field :content_id, type: String
  field :title, type: String
  field :description, type: Hash, default: { "value" => nil }
  field :format, type: String
  field :document_type, type: String
  field :schema_name, type: String
  field :locale, type: String, default: I18n.default_locale.to_s
  field :need_ids, type: Array, default: []
  field :first_published_at, type: DateTime
  field :public_updated_at, type: DateTime
  field :details, type: Hash, default: {}
  field :publishing_app, type: String
  field :rendering_app, type: String
  field :routes, type: Array, default: []
  field :redirects, type: Array, default: []
  field :links, type: Hash, default: {}
  field :expanded_links, type: Hash, default: {}
  field :access_limited, type: Hash, default: {}
  field :phase, type: String, default: 'live'
  field :analytics_identifier, type: String
  field :transmitted_at, type: String
  field :payload_version, type: Integer
  field :withdrawn_notice, type: Hash, default: {}

  scope :renderable_content, -> { where(:schema_name.nin => NON_RENDERABLE_FORMATS) }

  # The updated_at field isn't set on upsert - https://jira.mongodb.org/browse/MONGOID-3716
  before_upsert :set_updated_at

  # We want to look up related items by their content ID, excluding those that
  # are redirects; when multiple items exist, we take the most recent one, and
  # we need its base_path and its title. By indexing all these fields, we can
  # get hold of these related items purely from the index, without having to go
  # and fetch the entire document.
  index(content_id: 1, locale: 1, format: 1, updated_at: -1, title: 1, _id: 1)

  # We want to force the JSON representation to use "base_path" instead of
  # "_id" to prevent "_id" being exposed outside of the model.
  def as_json(options = nil)
    super(options).tap do |hash|
      hash["base_path"] = hash.delete("_id")
    end
  end

  # We store the description in a hash because Publishing API can send through
  # multiple content types.
  def description=(value)
    super("value" => value)
  end

  def description
    description = super

    if description.is_a?(Hash)
      description.fetch("value")
    else
      # This is here to ensure backwards compatibility during data migration:
      # db/migrate/20151130111755_description_value_hash.rb
      # It can be removed afterwards.
      description
    end
  end

  def redirect?
    self.schema_name == "redirect"
  end

  def gone?
    #we've overloaded gone a bit by adding explanation and alternative
    #url to the schema to support Whitehall unpublishing. We need to consider
    #things with an explanation as only being a bit gone and not return 410 from
    #content store or register a gone route. This is a fix until we implement an
    #alternative type of unpublishing through the stack as it is causing issues
    #in production
    self.schema_name == "gone" && self.details.empty?
  end

  def incoming_links(link_type, linking_document_type: nil)
    scope = ContentItem.where("links.#{link_type}" => { "$in" => [content_id] })
    scope = scope.where(document_type: linking_document_type) if linking_document_type
    scope
  end

  def viewable_by?(user_uid)
    !access_limited? || authorised_user_uids.include?(user_uid)
  end

  def register_routes(previous_item: nil)
    return if self.schema_name.start_with?("placeholder")
    return if previous_item && previous_item.route_set == self.route_set
    self.route_set.register!
  end

  def base_path_without_root
    return nil unless base_path

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
end
