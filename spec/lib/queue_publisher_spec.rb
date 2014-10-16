require 'queue_publisher'
require 'rails_helper'

describe QueuePublisher do
  context "real mode" do

    it 'sends a message with a routing key' do
      mock_exchange = double('exchange')
      allow_any_instance_of(QueuePublisher).to receive(:setup_connection)

      qp = QueuePublisher.new
      allow(qp).to receive(:with_exchange).and_yield(mock_exchange)

      expect(mock_exchange).to receive(:wait_for_confirms).and_return(true)

      item = build(:content_item, format: 'story', update_type: 'major')
      expect(mock_exchange).to receive(:publish) do |message, options|
        expect(options[:routing_key]).to eq('story.major')
      end
      qp.send_message(item)
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
