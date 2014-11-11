require "socket"
require "json"

class HeartbeatGenerator
  def initialize(exchange)
    @exchange = exchange
  end

  def generate
    @exchange.publish(heartbeat_message, headers: message_headers)
  end

private

  def heartbeat_message
    JSON.generate(
      {
        timestamp: Time.now.utc.iso8601,
        hostname: Socket.gethostname
      }
    )
  end

  def message_headers
    { content_type: "application/x-heartbeat" }
  end
end
