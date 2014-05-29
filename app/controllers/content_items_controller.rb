class ContentItemsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]

  def show
    item = ContentItem.find_by(:base_path => params[:base_path])
    render :json => item
  end

  def update
    item = ContentItem.new(:base_path => params[:base_path])
    item.assign_attributes(@request_data)

    if ContentItem.where(:base_path => params[:base_path]).exists?
      status_to_use = :ok
    else
      status_to_use = :created
    end
    item.upsert or status_to_use = :unprocessable_entity
    render :json => item, :status => status_to_use
  end

  private

  def parse_json_request
    @request_data = JSON.parse(request.body.read).except('base_path')
  rescue JSON::ParserError
    head :bad_request
  end
end
