require 'queue_publisher'
require 'spec_helper'

describe QueuePublisher do
  it 'does nothing when instantiated with noop' do
    qp = QueuePublisher.new(noop: true)
    expect(qp.channel).to be_nil
    expect(qp.exchange).to be_nil
    allow_message_expectations_on_nil
    expect(qp.exchange).not_to receive(:publish)
    qp.send_message('a message')
  end

  it 'sends a message with a routing key' do
    mock_bunny = double("Bunny")
    mock_exchange = double("exchange")
    mock_channel = double("channel")
    mock_channel.should_receive(:topic).with('content-store', {passive: true}).and_return(mock_exchange)
    mock_bunny.should_receive(:create_channel).and_return(mock_channel)
    mock_bunny.should_receive(:start)

    allow_any_instance_of(QueuePublisher).to receive(:connection).and_return(mock_bunny)
    qp = QueuePublisher.new

    item = ContentItem.new(format: 'story', update_type: 'major')
    expect(qp.exchange).to receive(:publish) do |message, options|
      expect(options[:routing_key]).to eq('story.major')
    end
    qp.send_message(item)
  end
end
