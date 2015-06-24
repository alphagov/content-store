class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]
  before_filter :set_cache_headers, :only => [:show]

  def show
    item = Rails.application.statsd.time('show.find_by') do
      ContentItem.find_by(:base_path => encoded_base_path)
    end

    if item.viewable_by?(authenticated_user_id)
      render :json => PublicContentItemPresenter.new(item, api_url_method)
    else
      render forbidden_json_response
    end
  end

  def update
    result, item = Rails.application.statsd.time('update.create_or_replace') do
      ContentItem.create_or_replace(encoded_base_path, @request_data)
    end

    if result
      status = (result == :created ? :created : :ok)
    else
      status = :unprocessable_entity
    end
    response_body = {}
    response_body[:errors] = item.errors.as_json if item.errors.any?
    render :json => response_body, :status => status
  end

  private

  def authenticated_user_id
    request.headers['X-Govuk-Authenticated-User']
  end

  def forbidden_json_response
    { :json => { :errors => { base: "Unauthorised" } }, status: 403 }
  end

  # The presenter needs context about routes and host names from controller
  # to know how to generate API URLs, so we can take the Rails helper and
  # pass that in as a callable
  def api_url_method
    if params[:public_api_request]
      method(:content_item_api_url)
    else
      method(:content_item_url)
    end
  end

  def set_cache_headers
    intent = PublishIntent.where(:base_path => encoded_base_path).first
    if intent && ! intent.past?
      expires_at bounded_expiry(intent.publish_time)
    else
      expires_at config.default_ttl.from_now
    end
  end

  # Calculate the TTL based on the publish_time but constrained to be within
  # the default_ttl and minimum_ttl.
  def bounded_expiry(publish_time)
    expiry = [config.default_ttl.from_now, publish_time].min
    min_expiry = config.minimum_ttl.from_now
    expiry >= min_expiry ? expiry : min_expiry
  end
end
