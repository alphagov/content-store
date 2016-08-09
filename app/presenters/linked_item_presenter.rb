# Presenter for generating the public-facing representation of content item links.
class LinkedItemPresenter
  attr_reader :linked_item, :api_url_method

  def initialize(linked_item, api_url_method)
    @linked_item = linked_item
    @api_url_method = api_url_method
  end

  def present
    return {} unless linked_item
    presented = {
      "content_id" => linked_item.content_id,
      "title" => linked_item.title,
      "base_path" => linked_item.base_path,
      "description" => ContentItemPresenter::RESOLVER.resolve(linked_item.description),
      "api_url" => api_url,
      "web_url" => web_url,
      "locale" => linked_item.locale,
      "links" => linked_item.links,
      "public_updated_at" => linked_item.public_updated_at,
      "schema_name" => linked_item.schema_name,
      "document_type" => linked_item.document_type
    }
    presented
  end

private

  def api_url
    return unless linked_item.base_path

    @api_url_method.call(linked_item.base_path_without_root)
  end

  def web_url
    return unless linked_item.base_path

    Plek.current.website_root + linked_item.base_path
  end
end
