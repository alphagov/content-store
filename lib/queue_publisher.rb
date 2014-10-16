class QueuePublisher
  def initialize(options = {})
    @noop = options[:noop]
    @options = options

    setup_exchange unless @noop
  end

  attr_reader :exchange, :channel

  class PublishFailedError < StandardError
  end

  def send_message(item)
    return if @noop
    routing_key = "#{item.format}.#{item.update_type}"
    body_data = presented_item(item)
    exchange.publish(
      body_data.to_json,
      routing_key: routing_key,
      content_type: 'application/json',
      persistent: true
    )
    success = channel.wait_for_confirms
    if !success
      Airbrake.notify_or_ignore(
        PublishFailedError.new("Publishing message failed"),
        parameters: {
          routing_key: routing_key,
          message_body: body_data,
        },
      )
    end
  end

  private

  def setup_exchange
    connection = Bunny.new(@options)
    connection.start
    @channel = connection.create_channel

    # Enable publisher confirms, so we get acks back after publishes.
    channel.confirm_select

    # passive parameter ensures we don't create the exchange.
    @exchange = channel.topic(@options.fetch(:exchange), passive: true)
  end

  def presented_item(item)
    PrivateContentItemPresenter.new(item).as_json
  end
end

