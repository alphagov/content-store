namespace :heartbeat_messages do
  desc "Send heartmessages to queue"
  task :send => :environment do
    config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env].symbolize_keys
    heartbeat_exchange = GovukExchange.new(config.fetch(:exchange), config: config)

    puts "Sending heartbeat message..."
    HeartbeatGenerator.new(heartbeat_exchange).generate
    puts "Heartbeat sent..."
  end
end
