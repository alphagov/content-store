# Presenter for generating the public-facing representation of content item links.
class LinkedItemPresenter
  attr_reader :linked_item, :api_url_method

  def initialize(linked_item, api_url_method)
    @linked_item = linked_item
    @api_url_method = api_url_method
  end

  def present
    presented = {
      "content_id" => linked_item.content_id,
      "title" => linked_item.title,
      "base_path" => linked_item.base_path,
      "description" => ContentItemPresenter::RESOLVER.resolve(linked_item.description),
      "api_url" => api_url(linked_item),
      "web_url" => web_url(linked_item),
      "locale" => linked_item.locale,
    }

    if linked_item.has_attribute?(:analytics_identifier)
      presented["analytics_identifier"] = linked_item.analytics_identifier
    end

    presented
  end

private
  def api_url(item)
    return nil unless item.base_path

    @api_url_method.call(item.base_path_without_root)
  end

  def web_url(item)
    return nil unless item.base_path

    Plek.current.website_root + item.base_path
  end
end
