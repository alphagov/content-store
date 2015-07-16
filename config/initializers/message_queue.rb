require 'queue_publisher'

if ENV['DISABLE_QUEUE_PUBLISHER']
  config = {noop: true}
elsif Rails.env.test? && ENV['ENABLE_QUEUE_IN_TEST_MODE'].blank?
  config = {noop: true}
else
  config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env].symbolize_keys
end
Rails.application.queue_publisher = QueuePublisher.new(config)
