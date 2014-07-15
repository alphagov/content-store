class QueuePublisher
  attr_reader :channel, :exchange, :noop

  def initialize(options = {})
    @noop = options[:noop]
    return if @noop
    connection.start
    @channel  = connection.create_channel
    @exchange = channel.topic("content_store")
  end

  def send_message(item)
    return if @noop
    hash = item.as_json
    hash["update_type"] = item.update_type
    message = hash.to_json
    routing_key = "#{item.format}.#{item.update_type}"
    @exchange.publish(message, routing_key: routing_key)
  end

  private

  def connection
    @connection ||= Bunny.new   # takes config from RABBITMQ_URL env var
  end

end

