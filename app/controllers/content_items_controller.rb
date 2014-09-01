require 'govuk/client/url_arbiter'

class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]
  before_filter :register_with_url_arbiter, :only => [:update]

  def show
    item = ContentItem.find_by(:base_path => params[:base_path])
    expires_at config.default_ttl.from_now
    render :json => item
  end

  def update
    result, item = ContentItem.create_or_replace(params[:base_path], @request_data)
    if result
      status = (result == :created ? :created : :ok)
    else
      status = :unprocessable_entity
    end
    render :json => item, :status => status
  end

  private

  def parse_json_request
    @request_data = JSON.parse(request.body.read).except('base_path')
  rescue JSON::ParserError
    head :bad_request
  end

  def register_with_url_arbiter
    Rails.application.url_arbiter_api.reserve_path(params["base_path"], "publishing_app" => @request_data["publishing_app"])
  rescue GOVUK::Client::Errors::Conflict => e
    item = ContentItem.new(@request_data.merge("base_path" => params[:base_path]))
    if e.response["errors"] and e.response["errors"]["base"]
      item.errors.set(:base_path, e.response["errors"]["base"])
    else
      item.errors.add(:base_path, "url-arbiter rejected registration: #{e.response.raw_body}")
    end
    render :json => item, :status => :conflict
  end
end
