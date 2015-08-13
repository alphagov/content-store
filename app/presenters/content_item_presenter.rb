# Presenter for generating the public-facing representation of content items.
#
# Any linked content items that exist in the content store are expanded out to
# include their title, base_path, api_url and web_url. See doc/output_examples
# for an example of what this representation looks like.
class ContentItemPresenter
  PUBLIC_ATTRIBUTES = %w(base_path title description format need_ids locale updated_at public_updated_at details phase).freeze

  def initialize(item, api_url_method)
    @item = item
    @api_url_method = api_url_method
  end

  def as_json(options = nil)
    @item.as_json(options).slice(*PUBLIC_ATTRIBUTES).merge("links" => links)
  end

private

  def links
    Rails.application.statsd.time('public_content_item_presenter.links') do
      @item.linked_items.each_with_object({}) do |(link_type, linked_items), items|
        items[link_type] = linked_items.map { |i| present_linked_item(i) }
      end
    end
  end

  def present_linked_item(linked_item)
    presented = {
      "title" => linked_item.title,
      "base_path" => linked_item.base_path,
      "description" => linked_item.description,
      "api_url" => api_url(linked_item),
      "web_url" => web_url(linked_item),
      "locale" => linked_item.locale,
    }
    presented["analytics_identifier"] = analytics_identifier(linked_item) if analytics_identifier(linked_item)
    presented
  end

  def api_url(item)
    @api_url_method.call(item.base_path)
  end

  def web_url(item)
    Plek.current.website_root + item.base_path
  end

  def analytics_identifier(item)
    item.has_attribute?(:details) && item.details.key?("analytics_identifier") && item.details[:analytics_identifier]
  end

end
