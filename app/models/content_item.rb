class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  def self.revert(previous_item:, item:)
    item.remove unless previous_item
    previous_item&.upsert
  end

  def self.create_or_replace(base_path, attributes)
    previous_item = ContentItem.where(base_path: base_path).first
    lock = UpdateLock.new(previous_item)

    payload_version = attributes["payload_version"]
    lock.check_availability!(payload_version)

    result = previous_item ? :replaced : :created

    item = ContentItem.new(base_path: base_path)
    item.assign_attributes(attributes)

    if item.upsert
      begin
        item.register_routes(previous_item: previous_item)
      rescue => e
        revert(previous_item: previous_item, item: item)
        raise unless e.is_a?(GdsApi::BaseError)
        item.errors.add(:routes, "Could not communicated with router.")
        result = false
      end
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
      }
    )
  end

  def self.find_by_path(path)
    ::FindByPath.new(self).find(path)
  end

  field :_id, as: :base_path, type: String, overwrite: true
  field :content_id, type: String
  field :title, type: String
  field :description, type: Hash, default: { "value" => nil }
  field :format, type: String
  field :document_type, type: String
  field :email_document_supertype, type: String, default: ''
  field :government_document_supertype, type: String, default: ''
  field :navigation_document_supertype, type: String, default: ''
  field :search_user_need_document_supertype, type: String, default: ''
  field :user_journey_document_supertype, type: String, default: ''
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
  field :payload_version, type: Integer
  field :withdrawn_notice, type: Hash, default: {}
  field :publishing_request_id, type: String, default: nil

  # The updated_at field isn't set on upsert - https://jira.mongodb.org/browse/MONGOID-3716
  before_upsert :set_updated_at

  # We want to look up content items by whether they match a route and the type
  # of route.
  index("routes.path" => 1, "routes.type" => 1)

  # We want to look up content items by whether they match a redirect and the
  # type of redirect.
  index("redirects.path" => 1, "redirects.type" => 1)

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
    schema_name == "gone" && details_is_empty?
  end

  def router_rendering_app
    # This is an extension of the hack in `gone?` method.
    #
    # For items that are registered in the content store which are not redirects
    # or gones we need to have a rendering_app. This is fine for all but the
    # "gone but not gone" exception defined in `gone?` where rendering_app is
    # not part of the schema for a gone but is required to register the route.
    #
    # This rather nastily fallsback to government frontend for gones that are
    # not gone and lack a rendering_app
    return rendering_app if schema_name != "gone" || gone?
    rendering_app || "government-frontend"
  end

  def viewable_by?(user_uid)
    authorised_user_uids.empty? || authorised_user_uids.include?(user_uid)
  end

  def includes_auth_bypass_id?(auth_bypass_id)
    auth_bypass_ids.include?(auth_bypass_id)
  end

  def register_routes(previous_item: nil)
    return unless should_register_routes?(previous_item: previous_item)

    tries = Rails.application.config.register_router_retries
    begin
      route_set.register!
    rescue GdsApi::BaseError
      tries -= 1
      tries.positive? ? retry : raise
    end
  end

  def delete_routes
    return unless should_register_routes?

    route_set.delete!
  end

  def base_path_without_root
    base_path&.sub(%r{^/}, "")
  end

protected

  def route_set
    @route_set ||= RouteSet.from_content_item(self)
  end

private

  def should_register_routes?(previous_item: nil)
    return false if self.schema_name.start_with?("placeholder")
    if previous_item
      return previous_item.schema_name == "placeholder" ||
          previous_item.route_set != self.route_set
    end
    true
  end

  def authorised_user_uids
    access_limited.fetch('users', [])
  end

  def auth_bypass_ids
    access_limited.fetch('auth_bypass_ids', [])
  end

  def details_is_empty?
    details.nil? || details.values.reject(&:blank?).empty?
  end
end
