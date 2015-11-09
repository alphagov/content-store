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
    transmitted_at = Float(transmitted_at)

    if lockable.present? && lockable.transmitted_at >= transmitted_at
      error = "Tried to process request with transmission time #{transmitted_at},"
      error += " but the latest #{lockable.class} has a newer (or equal) timestamp of #{lockable.transmitted_at}"
      raise OutOfOrderTransmissionError, error
    end
  end

  class ::MissingAttributeError < StandardError; end
  class ::OutOfOrderTransmissionError < StandardError; end
end
