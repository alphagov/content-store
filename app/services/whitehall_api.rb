class WhitehallApi < GdsApi::Base
  def content_item(path)
    get_json "#{base_url}#{path}"
  end

private

  def base_url
    "#{endpoint}/api"
  end
end
