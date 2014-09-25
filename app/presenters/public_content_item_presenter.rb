# A site-facing presenter for content items, which looks up information for
# published linked items
class PublicContentItemPresenter
  PUBLIC_ATTRIBUTES = %w(base_path title description format need_ids updated_at public_updated_at details).freeze

  def initialize(item)
    @item = item
  end

  def as_json(options = nil)
    @item.as_json(options).slice(*PUBLIC_ATTRIBUTES).merge("links" => links)
  end

private

  def links
    @item.linked_items.each_with_object({}) do |(link_type, linked_items), items|
      items[link_type] = linked_items.map { |i| present_linked_item(i) }
    end
  end

  def present_linked_item(linked_item)
    {
      "title" => linked_item.title,
      "base_path" => linked_item.base_path,
      "api_url" => api_url(linked_item),
      "web_url" => web_url(linked_item),
    }
  end

  def api_url(item)
    Plek.current.find("content-store") + "/content" + item.base_path
  end

  def web_url(item)
    Plek.current.website_root + item.base_path
  end
end
