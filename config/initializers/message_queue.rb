require 'queue_publisher'

if Rails.env.production? || ENV['USE_QUEUE_PUBLISHER']
  config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml")).symbolize_keys
else
  config = {noop: true}
end
Rails.application.queue_publisher = QueuePublisher.new(config)
