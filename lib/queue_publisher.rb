class QueuePublisher
  def initialize(options = {})
    @noop = options[:noop]
    @options = options

    setup_exchange unless @noop
  end

  attr_reader :exchange, :channel

  def send_message(item)
    return if @noop
    routing_key = "#{item.format}.#{item.update_type}"
    exchange.publish(
      item_json(item),
      routing_key: routing_key,
      content_type: 'application/json',
      persistent: true
    )
    success = channel.wait_for_confirms
    if !success
      Airbrake.notify_or_ignore(
        Exception.new("Publishing message failed"),
        parameters: {
          routing_key: routing_key,
          message_body: hash,
        },
      )
    end
  end

  private

  def setup_exchange
    connection = Bunny.new(@options)
    connection.start
    @channel = connection.create_channel
    channel.confirm_select

    # passive parameter ensures we don't create the exchange.
    @exchange = channel.topic(@options.fetch(:exchange), passive: true)
  end

  def item_json(item)
    PrivateContentItemPresenter.new(item).to_json
  end
end

