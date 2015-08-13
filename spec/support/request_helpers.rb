module RequestHelpers
  def get_content(content_item)
    get "/content#{content_item.base_path}"
  end

  def get_api_content(content_item)
    get "/api/content#{content_item.base_path}"
  end

  def default_ttl
    Rails.application.config.default_ttl
  end

  def cache_control
    Rack::Cache::CacheControl.new(response["Cache-Control"])
  end

  def present(content_item)
    stubbed_api_url_method = Proc.new { |path| "http://www.example.com/content/#{URI.encode(path)}" }

    ContentItemPresenter.new(content_item.reload, stubbed_api_url_method).to_json
  end
end

RSpec.configuration.include RequestHelpers
