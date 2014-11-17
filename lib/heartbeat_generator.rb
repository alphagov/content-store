require "socket"
require "json"

class HeartbeatGenerator
  def initialize(exchange)
    @exchange = exchange
  end

  def generate
    @exchange.publish(heartbeat_message, message_options)
  end

private

  ROUTING_KEY = "heartbeat.major"

  def heartbeat_message
    {
      timestamp: Time.now.utc.iso8601,
      hostname: Socket.gethostname,
    }.to_json
  end

  def message_options
    {
      routing_key: ROUTING_KEY,
      content_type: "application/x-heartbeat",
      persistent: false,
    }
  end
end
