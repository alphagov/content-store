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
      "schema_name" => linked_item.schema_name,
      "document_type" => linked_item.document_type
    }

    %i(analytics_identifier links).each do |attr|
      presented[attr.to_s] = linked_item.send(attr) if linked_item.has_attribute?(attr)
    end

    case linked_item.format
    # TODO: Remove placeholder case when Topical Events are migrated.
    when /(placeholder_)?topical_event/
      presented["details"] = linked_item.details.slice(:start_date, :end_date).stringify_keys
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
