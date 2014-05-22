class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]

  def show
    item = ContentItem.find_by(:base_path => params[:base_path])
    render :json => item
  end

  def update
    item = ContentItem.find_or_initialize_by(base_path: params[:base_path])
    status_to_use = item.new_record? ? :created : :ok
    item.update_attributes(@request_data) or status_to_use = :unprocessable_entity
    render :json => item, :status => status_to_use
  end

  private

  def parse_json_request
    @request_data = JSON.parse(request.body.read).except('base_path')
  rescue JSON::ParserError
    head :bad_request
  end
end
