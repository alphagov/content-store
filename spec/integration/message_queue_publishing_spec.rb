require 'rails_helper'

describe "publishing messages on the queue", :type => :request do
  include MessageQueueHelpers

  let(:data) {
    {
      "base_path" => "/vat-rates",
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "answer",
      "need_ids" => ["100123", "100124"],
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "publishing_app" => "publisher",
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

  context 'Creating or updating a content item'  do
    before :all do
      @config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env].symbolize_keys
      @old_publisher, Rails.application.queue_publisher = Rails.application.queue_publisher, QueuePublisher.new(@config)
    end

    after :all do
      Rails.application.queue_publisher = @old_publisher
    end

    around :each do |example|
      conn = Bunny.new(@config)
      conn.start
      read_channel = conn.create_channel
      ex = read_channel.topic(@config.fetch(:exchange), passive: true)
      @queue = read_channel.queue("", :exclusive => true)
      @queue.bind(ex, routing_key: '#')

      example.run

      read_channel.close
    end

    it 'should place a message on the queue' do
      put_json "/content/vat-rates", data
      delivery_info, properties, payload = wait_for_message_on(@queue)
      expect(delivery_info.routing_key).to eq('answer.major')
      expect(properties[:content_type]).to eq('application/json')
      message = JSON.parse(payload)
      expect(message['title']).to eq('VAT rates')

      # Check for a private field
      expect(message).to include('publishing_app')

      # Check specifically for the update type
      expect(message).to include('update_type')
    end

    it 'routing key depends on format and update type' do
      put_json "/content/vat-rates", data.update({"update_type" => "minor"})
      delivery_info, _, payload = wait_for_message_on(@queue)
      expect(delivery_info.routing_key).to eq('answer.minor')

      put_json "/content/vat-rates", data.update({"format" => "detailed_guide"})
      delivery_info, _, payload = wait_for_message_on(@queue)
      expect(delivery_info.routing_key).to eq('detailed_guide.minor')
    end

    it 'publishes a message for a redirect update' do
      data = {
        "base_path" => "/crb-checks",
        "format" => "redirect",
        "public_updated_at" => "2014-05-14T13:00:06Z",
        "publishing_app" => "publisher",
        "redirects" => [
          {"path" => "/crb-checks", "type" => "prefix", "destination" => "/dbs-checks"},
        ],
        "update_type" => "major",
      }
      put_json "/content/crb-checks", data
      delivery_info, _, _ = wait_for_message_on(@queue)
      expect(delivery_info.routing_key).to eq('redirect.major')
    end
  end
end
