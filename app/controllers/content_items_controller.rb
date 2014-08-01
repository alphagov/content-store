class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]

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
end
