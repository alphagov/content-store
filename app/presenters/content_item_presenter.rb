# Presenter for generating the public-facing representation of content items.
#
# Any linked content items that exist in the content store are expanded out to
# include their title, base_path, api_url and web_url. See doc/output_examples
# for an example of what this representation looks like.
class ContentItemPresenter
  RESOLVER = ContentTypeResolver.new("text/html")

  PUBLIC_ATTRIBUTES = %w(
    analytics_identifier
    base_path
    content_id
    document_type
    first_published_at
    format
    locale
    need_ids
    phase
    public_updated_at
    publishing_app
    rendering_app
    schema_name
    title
    updated_at
    withdrawn_notice
  ).freeze

  def initialize(item, api_url_method)
    @item = item
    @api_url_method = api_url_method
  end

  def as_json(options = nil)
    item.as_json(options).slice(*PUBLIC_ATTRIBUTES).merge(
      "links" => links,
      "description" => RESOLVER.resolve(item.description),
      "details" => RESOLVER.resolve(item.details),
    )
  end

private

  attr_reader :item, :api_url_method

  def links
    return item.expanded_links unless document_type_expanded?
    passthrough.merge(available_translations: available_translations)
  end

  def passthrough
    item.links.each_with_object({}) do |(link_type, passthrough_hash), result|
      passthrough, ids = passthrough_hash.partition { |type| type.is_a?(Hash) }
      hashes = passthrough.map { |attributes| present(ContentItem.new(attributes)) }
      content_items = content_items_for(ids).map { |content_item| present(content_item) }
      result[link_type] = hashes + content_items
    end
  end

  def content_items_for(content_ids)
    ContentItem
      .renderable_content
      .where(content_id: { "$in" => content_ids })
      .sort(updated_at: -1)
  end

  def available_translations
    ContentItem
      .renderable_content
      .where(content_id: item.content_id)
      .sort(locale: 1, updated_at: 1)
      .group_by(&:locale)
      .map { |_locale, items| present(items.last) }
  end

  def present(linked_item)
    LinkedItemPresenter.new(linked_item, api_url_method).present
  end

  def document_type_expanded?
    item.document_type =~ /travel_advice/
  end
end
