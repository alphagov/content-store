class UpdateLock
  def initialize(lockable)
    @lockable = lockable

    unless object_is_lockable?(lockable)
      raise ArgumentError, "#{lockable.class} must implement payload_version"
    end
  end

  def check_availability!(payload_version)
    return if lockable.blank?

    raise MissingAttributeError, "payload_version is required" if payload_version.blank?

    check_payload_version(payload_version, lockable)
  end

private

  attr_reader :lockable, :locked_at

  def object_is_lockable?(subject)
    subject.nil? || subject.respond_to?(:payload_version)
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
