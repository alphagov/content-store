class QueuePublisher
  def initialize(options = {})
    @noop = options[:noop]
    @options = options

    setup_exchange unless @noop
  end

  attr_reader :exchange

  def send_message(item)
    return if @noop
    routing_key = "#{item.format}.#{item.update_type}"
    exchange.publish(
      item_hash(item).to_json,
      routing_key: routing_key,
      content_type: 'application/json',
      persistent: true
    )
  end

  private

  def setup_exchange
    connection = Bunny.new(@options)
    connection.start
    channel = connection.create_channel

    # passive parameter ensures we don't create the exchange if it doesn't already exist.
    @exchange = channel.topic(@options.fetch(:exchange), passive: true)
  end

  def item_hash(item)
    PrivateContentItemPresenter.new(item).as_json
  end
end

