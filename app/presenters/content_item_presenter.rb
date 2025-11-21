# Presenter for generating the public-facing representation of content items.
#
# Any linked content items that exist in the content store are expanded out to
# include their title, base_path, api_url and web_url. See docs/output_examples
# for an example of what this representation looks like.

require "deepsort"

class ContentItemPresenter
  RESOLVER = ContentTypeResolver.new("text/html")

  PUBLIC_ATTRIBUTES = %w[
    analytics_identifier
    base_path
    content_id
    document_type
    first_published_at
    locale
    phase
    public_updated_at
    publishing_app
    publishing_scheduled_at
    rendering_app
    scheduled_publishing_delay_seconds
    schema_name
    title
    updated_at
    withdrawn_notice
    publishing_request_id
  ].freeze

  DATETIME_ATTRIBUTES = %w[
    updated_at
    public_updated_at
    first_published_at
    publishing_scheduled_at
  ].freeze

  def initialize(item)
    @item = item
  end

  def as_json(options = nil)
    item.as_json(options).slice(*PUBLIC_ATTRIBUTES).merge(
      "links" => RESOLVER.resolve(links),
      "description" => RESOLVER.resolve(item.description),
      "details" => RESOLVER.resolve(item.details),
    ).tap { |i|
      i["redirects"] = item["redirects"] if i["schema_name"] == "redirect"
      render_timestamps_as_iso8601(item, i)
    }.deep_stringify_keys.deep_sort(array: false)
  end

private

  attr_reader :item

  def links
    ExpandedLinksPresenter.new(item.expanded_links).present
  end

  def render_timestamps_as_iso8601(item, hash)
    DATETIME_ATTRIBUTES.each do |attr|
      hash[attr] = item[attr].iso8601 if item[attr].respond_to?(:iso8601)
    end
  end
end
