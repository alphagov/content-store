class QueuePublisher
  def initialize(options = {})
    @noop = options[:noop]
    @options = options

    setup_connection unless @noop
  end

  class PublishFailedError < StandardError
  end

  def send_message(item)
    return if @noop
    routing_key = "#{item.format}.#{item.update_type}"
    body_data = presented_item(item)
    with_exchange do |exchange|
      exchange.publish(
        body_data.to_json,
        routing_key: routing_key,
        content_type: 'application/json',
        persistent: true
      )
      success = exchange.wait_for_confirms
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
  end

  private

  def with_exchange
    channel = @connection.create_channel

    # Enable publisher confirms, so we get acks back after publishes.
    channel.confirm_select

    # passive parameter ensures we don't create the exchange.
    exchange = channel.topic(@options.fetch(:exchange), passive: true)
    yield exchange
  ensure
    channel.close if channel
  end

  def setup_connection
    @connection = Bunny.new(@options)
    @connection.start
  end

  def presented_item(item)
    PrivateContentItemPresenter.new(item).as_json
  end
end

