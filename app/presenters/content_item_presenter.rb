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
    expanded_links
    format
    locale
    need_ids
    phase
    publishing_app
    rendering_app
    schema_name
    title
    withdrawn_notice
  ).freeze

  def initialize(item, api_url_method)
    @item = item
    @api_url_method = api_url_method
  end

  def as_json(options = nil)
    @item.as_json(options).slice(*PUBLIC_ATTRIBUTES)
      .merge(datetimes)
      .merge(
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
    LinkedItemPresenter.new(linked_item, @api_url_method).present
  end

  def datetimes
    hash = {}
    hash["first_published_at"] = @item.first_published_at.iso8601 if @item.first_published_at
    hash["public_updated_at"] = @item.public_updated_at.iso8601 if @item.public_updated_at
    hash["updated_at"] = @item.updated_at.iso8601 if @item.updated_at
    hash
  end
end
