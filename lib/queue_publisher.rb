class QueuePublisher
  attr_reader :channel, :exchange, :noop

  def initialize(options = {})
    @noop = options[:noop]
    unless @noop
      @connection = Bunny.new   # takes config from RABBITMQ_URL env var
      @connection.start
      @channel  = @connection.create_channel
      @exchange = channel.topic("content_store")
    end
  end

  def publish(item)
    if connected?
      hash = item.as_json
      hash["update_type"] = item.update_type
      message = hash.to_json
      routing_key = "#{item.format}.#{item.update_type}"
      @exchange.publish(message, routing_key: routing_key)
    end
  end

  def connected?
    !@noop && @connection.connected?
  end
end

