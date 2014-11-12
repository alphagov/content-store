require_relative '../govuk_exchange'
require_relative '../heartbeat_generator'

namespace :heartbeat_messages do
  desc "Send heartmessages to queue"
  task :send => :environment do
    config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env].symbolize_keys
    exchange_name = config.delete(:exchange)
    heartbeat_exchange = GovukExchange.new(exchange_name, config: config)

    puts "Sending heartbeat message..."
    HeartbeatGenerator.new(heartbeat_exchange).generate
    puts "Heartbeat sent."
  end
end
