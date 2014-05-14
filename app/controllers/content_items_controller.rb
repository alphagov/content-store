class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]

  def show
    item = ContentItem.find_by(:base_path => params[:base_path])
    render :json => item
  end

  def update
    item = ContentItem.where(:base_path => params[:base_path]).first
    unless item
      item = ContentItem.new
      item.base_path = params[:base_path]
    end
    status_to_use = item.new_record? ? :created : :ok
    if item.update_attributes(@request_data)
      head status_to_use
    else
      render :json => item, :status => :unprocessable_entity
    end
  end

  private

  def parse_json_request
    @request_data = JSON.parse(request.body.read)
  rescue JSON::ParserError
    head :bad_request
  end
end
