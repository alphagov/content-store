require "spec_helper"
require "bunny"
require_relative "../../lib/govuk_exchange"

describe GovukExchange, "#publish" do
  let(:config) {{
    :host => "rabbitmq.example.com",
    :port => 5672,
    :user => "test_user",
    :pass => "super_secret",
    :recover_from_connection_close => true,
  }}

  let(:mock_message) { double("mock_message") }
  let(:mock_channel) { double("mock_channel", confirm_select: true, wait_for_confirms: nil, close: nil, topic: mock_exchange) }
  let(:mock_exchange) { double("mock_exchange", publish: nil) }
  let(:mock_connection) { double("mock_connection", create_channel: mock_channel, start: nil, close: nil, next_channel_id: nil) }

  before :each do
    allow(Bunny).to receive(:new).with(config).and_return(mock_connection)
  end

  it "starts the connection and the channel and gets a reference to the exchange" do
    govuk_exchange = GovukExchange.new("test_exchange", config: config)

    govuk_exchange.publish mock_message

    expect(mock_connection).to have_received(:create_channel)
    expect(mock_channel).to have_received(:topic).with("test_exchange", passive: true)
  end

  it "publishes to an exchange" do
    govuk_exchange = GovukExchange.new("test_exchange", config: config)

    govuk_exchange.publish mock_message

    expect(mock_exchange).to have_received(:publish).with(mock_message, {})
  end

  it "confirms the publish" do
    govuk_exchange = GovukExchange.new("test_exchange", config: config)

    govuk_exchange.publish mock_message

    expect(mock_channel).to have_received(:confirm_select)
    expect(mock_channel).to have_received(:wait_for_confirms)
  end

  it "closes the connection and the channel" do
    govuk_exchange = GovukExchange.new("test_exchange", config: config)

    govuk_exchange.publish mock_message

    expect(mock_channel).to have_received(:close)
    expect(mock_connection).to have_received(:close)
  end
end
