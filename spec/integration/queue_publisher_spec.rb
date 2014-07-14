require 'spec_helper'

describe "publishing messages on the queue" do
  let(:data) {
    {
      "base_path" => "/vat-rates",
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "answer",
      "need_ids" => ["100123", "100124"],
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "rendering_app" => "frontend",
      "details" => {
        "body" => "<p>Some body text</p>\n",
      },
      "routes" => [
        { "path" => "/vat-rates", "type" => 'exact' }
      ],
      "update_type" => "major",
    }
  }
  before :all do
    @publisher = QueuePublisher.new
    @queue = @publisher.channel.queue('content-store-test')
    @queue.bind(@publisher.exchange, routing_key: '#')
  end

  before :each do
    allow(Rails.application).to receive(:queue_publisher) { @publisher }
  end

  context 'Creating or updating a content item'  do
    it 'should place a message on the queue' do
      put_json "/content/vat-rates", data
      expect(@queue.message_count).to eq(1)
      # Get message synchronously for testing purposes.
      delivery_info, _, payload = @queue.pop
      expect(delivery_info.routing_key).to eq('answer.major')
      message = JSON.parse(payload)
      expect(message['title']).to eq('VAT rates')
    end

    it 'routing key depends on format and update type' do
      put_json "/content/vat-rates", data.update({"update_type" => "minor"})
      delivery_info, _, payload = @queue.pop
      expect(delivery_info.routing_key).to eq('answer.minor')

      put_json "/content/vat-rates", data.update({"format" => "detailed_guide"})
      delivery_info, _, payload = @queue.pop
      expect(delivery_info.routing_key).to eq('detailed_guide.minor')
    end

    it 'publishes a message for a redirect update' do
      data = {
        "base_path" => "/crb-checks",
        "format" => "redirect",
        "public_updated_at" => "2014-05-14T13:00:06Z",
        "redirects" => [
          {"path" => "/crb-checks", "type" => "prefix", "destination" => "/dbs-checks"},
        ],
        "update_type" => "major",
      }
      put_json "/content/crb-checks", data
      delivery_info, _, _ = @queue.pop
      expect(delivery_info.routing_key).to eq('redirect.major')
    end
  end
end
