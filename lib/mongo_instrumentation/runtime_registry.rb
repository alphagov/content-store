require "active_support/per_thread_registry"

module MongoInstrumentation
  # This is a namespaced thread locals registry for tracking the duration of
  # mongo queries.
  #
  # See the documentation of ActiveSupport::PerThreadRegistry for further
  # details.
  class RuntimeRegistry
    extend ActiveSupport::PerThreadRegistry

    attr_accessor :mongo_runtime
  end
end
