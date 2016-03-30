class ContentItemsController < ApplicationController
  before_filter :parse_json_request, only: [:update]

  def show
    item = Rails.application.statsd.time('show.find_content_item') do
      ContentItem.where(base_path: encoded_base_path).first
    end

    intent = Rails.application.statsd.time('show.find_publish_intent') do
      PublishIntent.where(base_path: encoded_base_path).first
    end

    set_cache_headers(item, intent)

    raise Mongoid::Errors::DocumentNotFound.new(
      ContentItem, base_path: encoded_base_path
    ) unless item

    if item.viewable_by?(authenticated_user_uid)
      render json: ContentItemPresenter.new(item, api_url_method)
    else
      render json_forbidden_response
    end
  end

  def update
    result, item = Rails.application.statsd.time('update.create_or_replace') do
      ContentItem.create_or_replace(encoded_base_path, @request_data)
    end

    response_body = {}
    case result
    when :created
      status = :created
    when :conflict
      status = :conflict
      response_body = { errors: item.errors.as_json }
    when false
      status = :unprocessable_entity
      response_body = { errors: item.errors.as_json }
    else
      status = :ok
    end

    render json: response_body, status: status
  end

  def destroy
    ContentItem.find_by(base_path: base_path).destroy
  end

private

  def authenticated_user_uid
    request.headers['X-Govuk-Authenticated-User']
  end

  def json_forbidden_response
    {
      json: {
        errors: {
          type: "access_forbidden",
          code: "403",
          message: "You do not have permission to access this resource",
        }
      },
      status: 403
    }
  end

  def set_cache_headers(item, intent)
    cache_time = config.default_ttl
    is_public = true

    if intent && !intent.past?
      cache_time = (intent.publish_time.to_i - Time.zone.now.to_i)
    elsif item && item.access_limited?
      cache_time = config.minimum_ttl
      is_public = false
    elsif item && max_cache_time(item)
      cache_time = max_cache_time(item)
    end

    expires_in bounded_max_age(cache_time), public: is_public
  end

  # Constrain the cache time to be within the minimum_ttl and default_ttl.
  def bounded_max_age(cache_time)
    if cache_time > config.default_ttl
      config.default_ttl
    elsif cache_time < config.minimum_ttl
      config.minimum_ttl
    else
      cache_time
    end
  end

  def max_cache_time(item)
    return unless item.try(:details)
    item.details["max_cache_time"]
  end
end
