class LinkedItemsController < ApplicationController
  def incoming_links
    item = ContentItem.find_by(base_path: encoded_base_path)
    links = IncomingLinksPresenter.new(item, params.fetch(:types), api_url_method)
    render json: links
  end
end
