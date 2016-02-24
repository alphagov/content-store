class UpdateLock
  def initialize(lockable)
    @lockable = lockable

    unless object_is_lockable?(lockable)
      raise ArgumentError.new("#{lockable.class} must implement transmitted_at or payload_version")
    end
  end

  def check_availability!(attributes)
    return unless lockable.present?

    attributes = attributes.with_indifferent_access

    validate_attributes(attributes)

    payload_version, transmitted_at = attributes.values_at(:payload_version, :transmitted_at)

    perform_check(payload_version, transmitted_at, lockable)
  end

private

  attr_reader :lockable, :locked_at

  def object_is_lockable?(subject)
    subject.nil? ||
      subject.respond_to?(:transmitted_at) ||
      subject.respond_to?(:payload_version)
  end

  def validate_attributes(attributes)
    if attributes[:transmitted_at].blank? && attributes[:payload_version].blank?
      raise MissingAttributeError,
        "transmitted_at or payload_version is required"
    end
  end

  def perform_check(payload_version, transmitted_at, lockable)
    if payload_version
      check_payload_version(payload_version, lockable)
    else
      check_transmitted_at(transmitted_at, lockable)
    end
  end

  def check_transmitted_at(transmitted_at, lockable)
    if lockable.transmitted_at.to_i >= transmitted_at.to_i
      raise_out_of_order_error(lockable, :transmitted_at, transmitted_at)
    end
  end

  def check_payload_version(payload_version, lockable)
    if lockable.payload_version.to_i >= payload_version.to_i
      raise_out_of_order_error(lockable, :payload_version, payload_version)
    end
  end

  def raise_out_of_order_error(lockable, field, value)
    error = "Tried to process request with #{field} #{value}, "\
            "but the latest ContentItem has a newer (or equal) "\
            "#{field} of #{lockable.send(field)}"
    raise OutOfOrderTransmissionError, error
  end

  class ::MissingAttributeError < StandardError; end
  class ::OutOfOrderTransmissionError < StandardError; end
end
