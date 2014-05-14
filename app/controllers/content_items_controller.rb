class ContentItemsController < ApplicationController
  def show
    item = ContentItem.find_by(:base_path => params[:base_path])
    render :json => item
  end
end
