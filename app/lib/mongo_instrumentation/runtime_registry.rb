require "active_support/per_thread_registry"

module MongoInstrumentation
  # This is a namespaced thread locals registry for tracking the duration of
  # mongo queries.
  class RuntimeRegistry
    thread_mattr_accessor :mongo_runtime, instance_accessor: false
  end
end
