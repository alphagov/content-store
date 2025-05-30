class ContentItem < ApplicationRecord
  validates_each :routes, :redirects do |record, attr, value|
    # This wording replicates the original Mongoid error message - we don't know if any downstream
    # consumers rely on parsing error messages at the moment
    record.errors.add attr, "Value of type #{value.class} cannot be written to a field of type Array" unless value.nil? || value.respond_to?(:each)
  end

  def self.revert(previous_item:, item:)
    item.destroy! unless previous_item
    previous_item&.save!
  end

  def self.create_or_replace(base_path, attributes, log_entry)
    previous_item = ContentItem.where(base_path:).first

    lock = UpdateLock.new(previous_item)

    payload_version = attributes["payload_version"]
    lock.check_availability!(payload_version)

    result = previous_item ? :replaced : :created

    # This doesn't seem to get set correctly on an upsert so this is to
    # maintain it
    created_at = previous_item ? previous_item.created_at : Time.zone.now.utc

    # This awkward construction is necessary to maintain the required behaviour -
    # a content item sent to Content Store is a complete entity (as defined in a schema)
    # and no-remnants of the item it replaces should remain.
    item = ContentItem.new(base_path:)
    item.assign_attributes(
      attributes
        .merge(scheduled_publication_details(log_entry))
        .merge(created_at:)
        .compact,
    )

    if previous_item
      previous_item.assign_attributes(
        item.attributes.except("id", "created_at", "updated_at"),
      )
      item = previous_item
    end

    begin
      transaction do
        item.save!
      end
    rescue StandardError
      result = false
      raise
    end

    [result, item]
  rescue ActiveRecord::UnknownAttributeError
    extra_fields = attributes.keys - new.attributes.keys
    item.errors.add(:base, "unrecognised field(s) #{extra_fields.join(', ')} in input")
    [false, item]
  rescue ActiveRecord::RecordInvalid => e
    item.errors.add(:base, e.message)
    [false, item]
  rescue OutOfOrderTransmissionError => e
    [
      :conflict,
      OpenStruct.new(
        errors: {
          type: "conflict",
          code: "409",
          message: e.message,
        },
      ),
    ]
  end

  def self.find_by_path(path)
    ::FindByPath.new(self).find(path)
  end

  # Prevent "id" being exposed outside of the model - it's synthetic and
  # only of internal use. Other applications should use `content_id` or
  # `base_path` as their unique identifiers.
  def as_json(options = nil)
    super(options).except("id")
  end

  # We store the description in a hash because Publishing API can send through
  # multiple content types.
  def description=(value)
    # ...but only wrap the given value in a Hash if it's not already a Hash
    value.is_a?(Hash) ? super : super("value" => value)
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

  def gone?
    # we've overloaded gone a bit by adding explanation and alternative
    # url to the schema to support Whitehall unpublishing. We need to consider
    # things with an explanation as only being a bit gone and not return 410 from
    # content store or register a gone route. This is a fix until we implement an
    # alternative type of unpublishing through the stack as it is causing issues
    # in production
    schema_name == "gone" && details_is_empty?
  end

  def valid_auth_bypass_id?(auth_bypass_id)
    return false unless auth_bypass_id
    return true if auth_bypass_ids&.include?(auth_bypass_id)
    return false if access_limited?

    # check for linked auth_bypass_id in top level expanded links
    expanded_links.values.flatten.any? do |link|
      link.fetch("auth_bypass_ids", []).include?(auth_bypass_id)
    end
  end

  def user_granted_access?(user_id:, user_organisation_id:)
    return false if user_id.nil? && user_organisation_id.nil?

    access_limited_user_ids.include?(user_id) ||
      access_limited_organisation_ids.include?(user_organisation_id)
  end

  def access_limited?
    access_limited_user_ids.any? || access_limited_organisation_ids.any?
  end

  def base_path_without_root
    base_path&.sub(%r{^/}, "")
  end

private

  def access_limited_user_ids
    access_limited.fetch("users", [])
  end

  def access_limited_organisation_ids
    access_limited.fetch("organisations", [])
  end

  def details_is_empty?
    details.nil? || details.values.reject(&:blank?).empty?
  end

  def self.scheduled_publication_details(log_entry)
    return {} unless log_entry

    {
      publishing_scheduled_at: log_entry.scheduled_publication_time,
      scheduled_publishing_delay_seconds: log_entry.delay_in_milliseconds / 1000,
    }
  end

  private_class_method :scheduled_publication_details
end
