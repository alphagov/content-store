class ContentItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :parse_json_request, only: [:update]
  before_action :set_cors_headers, only: [:show]

  def show
    item = GovukStatsd.time("show.find_content_item") do
      ContentItem.find_by_path(encoded_request_path)
    end

    intent = GovukStatsd.time("show.find_publish_intent") do
      PublishIntent.find_by_path(encoded_request_path)
    end

    set_cache_headers(item, intent)

    return error_404 unless item
    return redirect_canonical(item) if item.base_path != encoded_request_path

    if can_view?(item)
      render json: ContentItemPresenter.new(item, api_url_method), status: http_status(item)
    else
      render json_forbidden_response
    end
  end

  def update
    intent = PublishIntent.find_by_path(encoded_base_path)
    log_entry = find_or_create_scheduled_publishing_log(encoded_base_path, @request_data["document_type"], intent)

    result, item = GovukStatsd.time("update.create_or_replace") do
      ContentItem.create_or_replace(encoded_base_path, @request_data, log_entry)
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

    render json: response_body, status:
  end

  def destroy
    content_item = ContentItem.find_by(base_path: encoded_base_path)

    content_item.delete_routes
    content_item.destroy!

    render status: :ok
  end

private

  def redirect_canonical(content_item)
    route = api_url_method.call(content_item.base_path_without_root)
    redirect_to route, status: :see_other
  end

  def can_view?(item)
    return true if item.user_granted_access?(
      user_id: auth_user_id,
      user_organisation_id: auth_organisation_id,
    )
    return true if item.valid_auth_bypass_id?(auth_bypass_id)
    return false if item.access_limited?

    !restricted_access?
  end

  def restricted_access?
    # we assume that the presence of an auth_bypass_id without an auth_user_id
    # means a user on the draft stack using only a token without being signed
    # in. These users should only be able to access specific content that
    # is valid for that auth bypass id
    auth_user_id.nil? && auth_bypass_id.present?
  end

  def auth_user_id
    request.headers["X-Govuk-Authenticated-User"].then do |user_id|
      # Authenticating proxy sets this to invalid rather than nil when a user
      # is not signed in.
      user_id == "invalid" ? nil : user_id.presence
    end
  end

  def auth_organisation_id
    request.headers["X-Govuk-Authenticated-User-Organisation"].then do |org_id|
      org_id == "invalid" ? nil : org_id.presence
    end
  end

  def auth_bypass_id
    request.headers["Govuk-Auth-Bypass-Id"].presence
  end

  def json_forbidden_response
    {
      json: {
        errors: {
          type: "access_forbidden",
          code: "403",
          message: "You do not have permission to access this resource",
        },
      },
      status: 403,
    }
  end

  def set_cache_headers(item, intent)
    cache_time = config.default_ttl
    is_public = true

    if item && (auth_bypass_id.present? || item.access_limited?)
      cache_time = config.minimum_ttl
      is_public = false
    elsif intent && !intent.past?
      cache_time = (intent.publish_time.to_i - Time.zone.now.to_i)
    elsif item && max_cache_time(item)
      cache_time = max_cache_time(item)
    end

    expires_in bounded_max_age(cache_time), public: is_public
  end

  def set_cors_headers
    # Allow any origin host to request the resource
    response.headers["Access-Control-Allow-Origin"] = "*"
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
    item.gone? ? 410 : 200
  end

  def find_or_create_scheduled_publishing_log(base_path, document_type, intent)
    latest_log_entry = ScheduledPublishingLogEntry
      .where(base_path:)
      .order_by(:scheduled_publication_time.desc)
      .first

    if new_scheduled_publishing?(intent, document_type, latest_log_entry)
      latest_log_entry = ScheduledPublishingLogEntry.create!(
        base_path:,
        document_type:,
        scheduled_publication_time: intent.publish_time,
      )
      GovukStatsd.timing("scheduled_publishing.delay_ms", latest_log_entry.delay_in_milliseconds)
    end

    latest_log_entry
  end

  def new_scheduled_publishing?(intent, document_type, latest_log_entry)
    intent.present? &&
      intent.publish_time.past? &&
      document_type != "coming_soon" &&
      (!latest_log_entry || intent.publish_time > latest_log_entry.scheduled_publication_time)
  end
end
