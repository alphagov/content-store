require 'queue_publisher'

if Rails.env.production? || ENV['USE_QUEUE_PUBLISHER']
  Rails.application.queue_publisher = QueuePublisher.new
else
  Rails.application.queue_publisher = QueuePublisher.new(noop: true)
end
