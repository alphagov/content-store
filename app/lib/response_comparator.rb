class ResponseComparator
  def initialize(path_file:, host_1:, host_2:, output_file:)
    @path_file = path_file
    @host_1 = host_1
    @host_2 = host_2
    @output_file = output_file
  end

  def call
    File.open(@output_file, "w+") do |out|
      out.write(headers.join("\t"))
      i = 0
      IO.foreach(@path_file) do |line|
        path = line.strip
        Rails.logger.info "#{i} - #{path}"
        result = compare(host_1: @host_1, host_2: @host_2, path: path)
        out.write(result.join("\t") + "\n")
        i = i + 1
      end
    end
  end

private

  def compare(host_1:, host_2:, path:)
    response_1 = hit_url(host_1, path)
    response_2 = hit_url(host_2, path)
    result_line = results(path:, response_1:, response_2:)
  end

  def hit_url(host, path)
    t = Time.now
    response = Net::HTTP.get_response(host, "/api/content" + path)
    body_size = response.body.strip.length
    time = Time.now - t
    { 
      status: response.code,
      body_size: ,
      time: ,
    }
  end

  def headers
    ["url", "host-1-status", "host-1-body-size", "host-1-response-time", "host-2-status", "host-2-body-size", "host-2-response-time"]
  end
  
  def results(path:, response_1:, response_2:)
    [
      path,
      response_1[:status],
      response_1[:body_size],
      response_1[:time],
      response_2[:status],
      response_2[:body_size],
      response_2[:time],
    ]
  end
  
end