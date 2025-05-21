module RequestHelpers
  def default_ttl
    Rails.application.config.default_ttl
  end

  def minimum_ttl
    Rails.application.config.minimum_ttl
  end

  def cache_control
    Rack::Cache::CacheControl.new(response["Cache-Control"])
  end

  def present(content_item)
    ContentItemPresenter.new(content_item.reload, "text/html").to_json
  end
end

RSpec.configuration.include RequestHelpers
