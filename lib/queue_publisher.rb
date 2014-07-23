class QueuePublisher
  attr_reader :channel, :exchange, :noop

  def initialize(options = {})
    @noop = options[:noop]
    @options = options
    return if @noop
    connection.start
    @channel  = connection.create_channel
    # passive parameter ensures we don't create the exchange if it doesn't
    # already exist.
    @exchange = channel.topic(@options.fetch(:exchange, 'content-store'),
                              passive: true)
  end

  def send_message(item)
    return if @noop
    hash = item.as_json
    hash["update_type"] = item.update_type
    message = hash.to_json
    routing_key = "#{item.format}.#{item.update_type}"
    exchange.publish(message, routing_key: routing_key, persistent: true)
  end

  private

  def connection
    @connection ||= Bunny.new(@options)
  end

end

