# Presenter for generating the public-facing representation of content items.
#
# Any linked content items that exist in the content store are expanded out to
# include their title, base_path, api_url and web_url. See doc/output_examples
# for an example of what this representation looks like.
class ContentItemPresenter
  RESOLVER = ContentTypeResolver.new("text/html")

  PUBLIC_ATTRIBUTES = %w(
    base_path
    content_id
    title
    format
    need_ids
    locale
    updated_at
    public_updated_at
    phase
    analytics_identifier
  ).freeze

  def initialize(item, api_url_method)
    @item = item
    @api_url_method = api_url_method
  end

  def as_json(options = nil)
    @item.as_json(options).slice(*PUBLIC_ATTRIBUTES).merge(
      "links" => links,
      "description" => RESOLVER.resolve(@item.description),
      "details" => RESOLVER.resolve(@item.details),
    )
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
      "content_id" => linked_item.content_id,
      "title" => linked_item.title,
      "base_path" => linked_item.base_path,
      "description" => RESOLVER.resolve(linked_item.description),
      "api_url" => api_url(linked_item),
      "web_url" => web_url(linked_item),
      "locale" => linked_item.locale,
    }
    if linked_item.has_attribute? :analytics_identifier
      presented["analytics_identifier"] = linked_item.analytics_identifier
    end
    presented
  end

  def api_url(item)
    @api_url_method.call(item.base_path_without_root)
  end

  def web_url(item)
    Plek.current.website_root + item.base_path
  end
end
