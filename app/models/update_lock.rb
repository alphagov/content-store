class UpdateLock
  attr_reader :lockable, :locked_at

  def initialize(lockable)
    @lockable = lockable

    if lockable && !lockable.respond_to?(:transmitted_at)
      raise OutOfOrderTransmissionError.new("#{lockable.class} must implement transmitted_at")
    end
  end

  def check_availability!(transmitted_at)
    raise MissingAttributeError, "transmitted_at is mandatory" unless transmitted_at
    return unless lockable.present?

    request_transmitted_at = Integer(transmitted_at)
    database_transmitted_at = Integer(lockable.transmitted_at)

    if database_transmitted_at >= request_transmitted_at
      error = "Tried to process request with transmission time #{request_transmitted_at},"
      error += " but the latest #{lockable.class} has a newer (or equal) timestamp of #{lockable.transmitted_at}"
      raise OutOfOrderTransmissionError, error
    end
  end

  class ::MissingAttributeError < StandardError; end
  class ::OutOfOrderTransmissionError < StandardError; end
end
