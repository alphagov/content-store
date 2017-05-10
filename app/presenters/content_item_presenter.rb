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
    email_document_supertype
    first_published_at
    format
    government_document_supertype
    locale
    navigation_document_supertype
    need_ids
    phase
    public_updated_at
    publishing_app
    rendering_app
    schema_name
    title
    updated_at
    user_journey_document_supertype
    withdrawn_notice
    publishing_request_id
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
    ExpandedLinksPresenter.new(item.expanded_links).present
  end
end
