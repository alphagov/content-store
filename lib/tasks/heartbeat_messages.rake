
namespace :heartbeat_messages do

  desc "Send heartmessages to queue"
  task :send => :environment do
    require_relative '../queue_publisher'
    config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env].symbolize_keys
    publisher = QueuePublisher.new(config)

    puts "Sending heartbeat message..."
    publisher.send_heartbeat
    puts "Heartbeat sent."
  end
end
