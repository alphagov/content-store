require 'govuk/client/url_arbiter'

class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]
  before_filter :register_with_url_arbiter, :only => [:update]
  before_filter :set_cache_headers, :only => [:show]

  def show
    item = Rails.application.statsd.time('show.find_by') do
      ContentItem.find_by(:base_path => encoded_base_path)
    end

    # The presenter needs context about routes and host names from controller
    # to know how to generate API URLs, so we can take the Rails helper and
    # pass that in as a callable
    api_url_method = method(:content_item_url)
    presenter = PublicContentItemPresenter.new(item, api_url_method)

    render :json => presenter
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

  def register_with_url_arbiter
    Rails.application.url_arbiter_api.reserve_path(encoded_base_path, "publishing_app" => @request_data["publishing_app"])
  rescue GOVUK::Client::Errors::Conflict => e
    return_arbiter_error(:conflict, e)
  rescue GOVUK::Client::Errors::UnprocessableEntity => e
    return_arbiter_error(:unprocessable_entity, e)
  rescue GOVUK::Client::Errors::BaseError => e
    return_arbiter_error(:server_error, e)
  end

  def return_arbiter_error(status, exception)
    response_errors = {}
    if exception.response["errors"]
      response_errors["url_arbiter_registration"] = []
      exception.response["errors"].each do |field, errors|
        response_errors["url_arbiter_registration"] += errors.map { |error| "#{field} #{error}" }
      end
    else
      response_errors["url_arbiter_registration"] = ["#{exception.response.code}: #{exception.response.raw_body}"]
    end
    render :json => { "errors" => response_errors }, :status => status
  end
end
