class QueuePublisher
  def initialize(options = {})
    @noop = options[:noop]
    return if @noop

    @exchange_name = options.fetch(:exchange)
    @options = options.except(:exchange)

    @connection = Bunny.new(@options)
    @connection.start
  end

  def exchange
    @exchange ||= connect_to_exchange
  end

  class PublishFailedError < StandardError
  end

  def send_message(item)
    return if @noop
    routing_key = "#{item.format}.#{item.update_type}"
    message_data = presented_item(item)
    exchange.publish(
      message_data.to_json,
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
          message_body: message_data,
        }
      )
    end
  rescue Timeout::Error, Bunny::Exception
    reset_channel
    raise
  end

  private

  def connect_to_exchange
    @channel = @connection.create_channel

    # Enable publisher confirms, so we get acks back after publishes.
    @channel.confirm_select

    # passive parameter ensures we don't create the exchange.
    @channel.topic(@exchange_name, passive: true)
  end

  def reset_channel
    @exchange = nil
    @channel.close if @channel and @channel.open?
    @channel = nil
  end

  def presented_item(item)
    PrivateContentItemPresenter.new(item).as_json
  end
end

