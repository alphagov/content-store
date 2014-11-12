class GovukExchange
  def initialize(name, config:)
    @name = name
    @config = config
  end

  def publish(message, headers: {})
    start_connection
    exchange.publish message, headers
    wait_for_confirmation
    close_channel_and_connection
  end

private

  attr_reader :name, :config

  def connection
    @_connection ||= Bunny.new(config)
  end

  def exchange
    @_exchange ||= channel.topic(name, passive: true)
  end

  def channel
    return @_channel if @_channel

    @_channel ||= connection.create_channel
    @_channel.confirm_select
    @_channel
  end

  def start_connection
    connection.start
  end

  def wait_for_confirmation
    channel.wait_for_confirms
  end

  def close_channel_and_connection
    channel.close
    connection.close
  end
end
