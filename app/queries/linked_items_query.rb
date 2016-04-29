class LinkedItemsQuery
  attr_reader :content_item

  MIGRATED_EDITION_FORMATS = %w(case_study detailed_guide).freeze

  def initialize(content_item)
    @content_item = content_item
  end

  def call
    items = linked_items
    items["available_translations"] = available_translations if available_translations.any?
    if content_item.format == "working_group"
      merge_inverse_links(items, "policies", "working_groups", "policy")
    elsif MIGRATED_EDITION_FORMATS.include? content_item.format
      merge_inverse_links(items, "document_collections", "documents", "placeholder_document_collection")
    end
    items
  end

private

  # Return the extant and renderable linked_items and any "passthrough" items
  # which aren't really content_items, but are instead hardcoded hashes.
  def linked_items
    outgoing_content_items = content_items(outgoing_link_content_ids)
    content_item.links.each_with_object({}) do |(link_type, raw_content_ids), result|
      passthrough_hashes, raw_content_ids = raw_content_ids.partition { |link| link.is_a?(Hash) }
      passthrough_content_items = passthrough_hashes.map do |attributes|
        ContentItem.new(attributes)
      end

      real_content_items = raw_content_ids.map do |id|
        outgoing_content_items.find { |ci| ci.content_id == id }
      end
      real_content_items.compact!
      result[link_type] = real_content_items + passthrough_content_items
    end
  end

  # Return the renderable items based on `content_ids`, in the most appropriate
  # locale
  def content_items(content_ids)
    # For each linked content_id find all non-redirect content items with
    # matching content_id in either this item's locale, or the default locale
    # with the most recently updated first.
    locales = [I18n.default_locale.to_s, content_item.locale].uniq
    renderable_items_by_id = ContentItem
      .renderable_content
      .where(content_id: { "$in" => content_ids })
      .where(locale: { "$in" => locales })
      .sort(updated_at: -1)
      .group_by(&:content_id)

    # For each set of items for a given content_id, pick the first one that
    # matches this item's locale, or fall back to the first one matching the
    # default locale.
    renderable_items_by_id.map do |_content_id, items|
      in_same_locale = items.find { |i| i.locale == content_item.locale }
      in_default_locale = items.find { |i| i.locale == I18n.default_locale.to_s }
      in_same_locale || in_default_locale
    end
  end

  # Returns the content_ids for all types of link ignoring passthrough hashes.
  def outgoing_link_content_ids
    content_item.links.values.flatten.uniq.reject { |link| link.is_a?(Hash) }
  end

  def incoming_link_content_ids(link_type, linking_format)
    content_item.incoming_links(link_type, linking_format: linking_format)
      .only(:content_id)
      .map(&:content_id)
  end

  def merge_inverse_links(items, link_type, incoming_link_type, linking_format)
    items[link_type] ||= []
    items[link_type] += content_items(incoming_link_content_ids(incoming_link_type, linking_format))
    items[link_type].uniq!(&:content_id)
  end

  def available_translations
    @_available_translations ||= begin
      if content_item.content_id.blank?
        []
      else
        ContentItem
          .renderable_content
          .where(content_id: content_item.content_id)
          .sort(locale: 1, updated_at: 1)
          .group_by(&:locale)
          .map { |_locale, items| items.last }
      end
    end
  end
end
