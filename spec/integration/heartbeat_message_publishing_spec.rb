require "rails_helper"
require_relative "../../lib/heartbeat_generator"
require_relative "../../lib/govuk_exchange"

describe "sending a heartbeat message on the queue", :type => :request do
  include MessageQueueHelpers

  around :each do |example|
    @config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env].symbolize_keys
    conn = Bunny.new(@config)
    conn.start
    read_channel = conn.create_channel
    ex = read_channel.topic(@config.fetch(:exchange), passive: true)
    @queue = read_channel.queue("", :exclusive => true)
    @queue.bind(ex, routing_key: '#')
    example.run

    read_channel.close
  end

  it "should place a heartbeat message on the queue" do
    heartbeat_exchange = GovukExchange.new(@config.fetch(:exchange), config: @config)
    HeartbeatGenerator.new(heartbeat_exchange).generate

    _, properties, payload = wait_for_message_on(@queue)
    message = JSON.parse(payload)

    expect(properties.content_type).to eq("application/x-heartbeat")
    expect(message.fetch("hostname")).to eq(Socket.gethostname)
    expect(message.fetch("routing_key")).to eq("heartbeat.major")
  end
end
