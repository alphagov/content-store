require "spec_helper"
require "bunny"
require "timecop"
require "json"
require_relative "../../lib/heartbeat_generator"

describe HeartbeatGenerator do
  let(:mock_exchange) { instance_double("Bunny::Exchange", :publish => nil, :wait_for_confirms => true) }

  before :each do
    allow(Bunny).to receive(:new) { mock_session }
  end

  it "sends a heartbeat message to a channel" do
    Timecop.freeze do
      allow(Socket).to receive(:gethostname) { "example-hostname" }
      expected_data = JSON.generate(
        {
          timestamp: Time.now.utc.iso8601,
          hostname: "example-hostname"
        }
      )

      HeartbeatGenerator.new(mock_exchange).generate

      expect(mock_exchange).to have_received(:publish).
        with(expected_data, headers: { :content_type => "application/x-heartbeat" })
    end
  end
end
