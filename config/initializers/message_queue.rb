require 'queue_publisher'

if Rails.env.test? || ENV['DISABLE_QUEUE_PUBLISHER']
  config = {noop: true}
else
  config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env].symbolize_keys
end
Rails.application.queue_publisher = QueuePublisher.new(config)
