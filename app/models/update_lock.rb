class UpdateLock
  attr_reader :lockable, :locked_at

  def initialize(lockable)
    @lockable = lockable

    if lockable && !lockable.respond_to?(:version)
      raise VersionLockError.new("#{lockable.class} must implement version")
    end
  end

  def check_availability!(version)
    version = Integer(version)

    if lockable.present? && lockable.version >= version
      raise VersionLockError, "Lock version is greater than or equal to given version (#{lockable.version} >= #{version})"
    end
  end

  class ::VersionLockError < StandardError; end
end
