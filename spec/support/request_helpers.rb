module RequestHelpers
  def default_ttl
    Rails.application.config.default_ttl
  end

  def cache_control
    Rack::Cache::CacheControl.new(response["Cache-Control"])
  end

  def public_presentation(content_item)
    stubbed_api_url_method = Proc.new { |path| "http://www.example.com/content#{URI.encode(path)}" }

    PublicContentItemPresenter.new(content_item.reload, stubbed_api_url_method).to_json
  end
end

RSpec.configuration.include RequestHelpers
