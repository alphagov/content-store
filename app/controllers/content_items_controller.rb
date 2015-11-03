class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]
  before_filter :set_default_cache_headers, :only => [:show]

  def show
    item = Rails.application.statsd.time('show.find_by') do
      ContentItem.find_by(:base_path => encoded_base_path)
    end

    if item.viewable_by?(authenticated_user_uid)
      set_cache_control_private if item.access_limited?
      render :json => ContentItemPresenter.new(item, api_url_method)
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
    when :stale
      status = :conflict
      response_body = { errors: "A later version is already stored" }
    when false
      status = :unprocessable_entity
      response_body = { errors: item.errors.as_json }
    else
      status = :ok
    end

    render json: response_body, status: status
  end

  private

  def authenticated_user_uid
    request.headers['X-Govuk-Authenticated-User']
  end

  def json_forbidden_response
    {
      :json => {
        :errors => {
          :type => "access_forbidden",
          :code => "403",
          :message => "You do not have permission to access this resource",
        }
      },
      status: 403
    }
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

  def set_default_cache_headers
    intent = PublishIntent.where(:base_path => encoded_base_path).first
    if intent && !intent.past?
      expires_in bounded_max_age(intent.publish_time), :public => true
    else
      expires_in config.default_ttl, :public => true
    end
  end

  def set_cache_control_private
    expires_in config.minimum_ttl, :public => false
  end

  # Calculate the max-age based on the publish_time but constrained to be within
  # the default_ttl and minimum_ttl.
  def bounded_max_age(publish_time)
    time_to_publish = (publish_time.to_i - Time.zone.now.to_i)

    if time_to_publish > config.default_ttl
      config.default_ttl
    elsif time_to_publish < config.minimum_ttl
      config.minimum_ttl
    else
      time_to_publish
    end
  end
end
