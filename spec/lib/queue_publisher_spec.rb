require 'rails_helper'

describe QueuePublisher do
  context "real mode" do

    let(:options) {{
      :host => "rabbitmq.example.com",
      :port => 5672,
      :user => "test_user",
      :pass => "super_secret",
      :recover_from_connection_close => true,
      :exchange => "test_exchange",
    }}
    let(:queue_publisher) { QueuePublisher.new(options) }

    let(:mock_session) { instance_double("Bunny::Session", :start => nil, :create_channel => mock_channel) }
    let(:mock_channel) { instance_double("Bunny::Channel", :confirm_select => nil, :topic => mock_exchange) }
    let(:mock_exchange) { instance_double("Bunny::Exchange", :publish => nil, :wait_for_confirms => true) }
    before :each do
      allow(Bunny).to receive(:new) { mock_session }
    end

    describe "setting up the connection etc" do
      it "connects to rabbitmq using the given parameters" do
        expect(Bunny).to receive(:new).with(options.except(:exchange)).and_return(mock_session)
        expect(mock_session).to receive(:start)

        queue_publisher
      end

      it "creates the channel and exchange" do
        expect(mock_session).to receive(:create_channel).and_return(mock_channel).ordered
        expect(mock_channel).to receive(:confirm_select).ordered
        expect(mock_channel).to receive(:topic).with(options[:exchange], :passive => true).and_return(mock_exchange).ordered

        expect(queue_publisher.exchange).to eq(mock_exchange)
      end

      it "memoizes the created channel and exchange" do
        first_result = queue_publisher.exchange

        expect(mock_session).not_to receive(:create_channel)
        expect(mock_channel).not_to receive(:confirm_select)
        expect(mock_channel).not_to receive(:topic)

        expect(queue_publisher.exchange).to eq(first_result)
      end
    end

    describe "sending a message" do
      let(:item) { build(:content_item, :format => "story", :update_type => "exquisite") }

      it "sends the private json representation of the item on the message queue" do
        expected_data = PrivateContentItemPresenter.new(item).as_json
        expect(mock_exchange).to receive(:publish).with(expected_data.to_json, hash_including(:content_type => "application/json"))

        queue_publisher.send_message(item)
      end

      it "uses a routing key of format.update_type" do
        expect(mock_exchange).to receive(:publish).with(anything, hash_including(:routing_key => "#{item.format}.#{item.update_type}"))

        queue_publisher.send_message(item)
      end

      it "sends the message as persistent" do
        expect(mock_exchange).to receive(:publish).with(anything, hash_including(:persistent => true))

        queue_publisher.send_message(item)
      end
    end

    describe "error handling" do

      context "when message delivery is not acknowledged positively" do

        it "notifies errbit with the message details"

      end

      context "when communication with rabbitmq fails" do

        it "raises the exception"

        it "closes the channel"

      end
    end
  end

  context "noop mode" do
    subject { QueuePublisher.new(noop: true) }

    it 'does nothing when instantiated with noop' do
      expect_any_instance_of(Bunny::Exchange).not_to receive(:publish)

      subject.send_message(:something)
    end
  end

end
