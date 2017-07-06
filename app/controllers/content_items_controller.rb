class ContentItemsController < ApplicationController
  before_action :parse_json_request, only: [:update]

  def show
    item = Rails.application.statsd.time('show.find_content_item') do
      ContentItem.find_by_path(encoded_request_path)
    end

    intent = Rails.application.statsd.time('show.find_publish_intent') do
      PublishIntent.find_by_path(encoded_request_path)
    end

    set_cache_headers(item, intent)

    return error_404 unless item
    return redirect_canonical(item) if item.base_path != encoded_request_path

    if can_view(item)
      render json: ContentItemPresenter.new(item, api_url_method), status: http_status(item)
    else
      render json_forbidden_response
    end
  end

  def update
    result, item = Rails.application.statsd.time('update.create_or_replace') do
      ContentItem.create_or_replace(encoded_base_path, @request_data)
    end

    intent = PublishIntent.find_by_path(encoded_base_path)
    if intent.present? && intent.publish_time.past?
      intent.destroy
      ScheduledPublishingLogEntry.create(
        base_path: item.base_path,
        document_type: item.document_type,
        scheduled_publication_time: intent.publish_time
      )
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
    ContentItem.find_by(base_path: encoded_base_path).destroy
    render status: :ok
  end

private

  def redirect_canonical(content_item)
    route = api_url_method.(content_item.base_path_without_root)
    redirect_to route, status: 303
  end

  def can_view(item)
    if auth_bypass_id_header.present?
      item.includes_auth_bypass_id?(auth_bypass_id_header)
    else
      !invalid_user_id? && item.viewable_by?(authenticated_user_uid)
    end
  end

  def authenticated_user_uid
    request.headers['X-Govuk-Authenticated-User']
  end

  def auth_bypass_id_header
    request.headers['Govuk-Auth-Bypass-Id']
  end

  def invalid_user_id?
    authenticated_user_uid == 'invalid'
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
    elsif item && (auth_bypass_id_header.present? || item.access_limited?)
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

  def http_status(item)
    return 410 if item.gone?
    200
  end
end
