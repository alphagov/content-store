require "csv"

class FindSpecificTerm
  attr_reader :term, :exclude_types

  CONTENT_ITEM_HEADERS = ["Title", "URL", "Publishing application", "Tagged organisation", "Format", "Content ID"].freeze

  def initialize(term, exclude_types = [])
    @term = term
    @exclude_types = exclude_types
  end

  def call
    report
  end

  def self.call(*args)
    new(*args).call
  end

private

  def report
    logger.info "Searching for #{term}..."

    logger.info CONTENT_ITEM_HEADERS.join(",")

    count = 0
    term_content_items.each do |content_item|
      unless excluded?(content_item)
        logger.info report_line(content_item)
        count += 1
      end
    end

    logger.info "Found #{count} items containing #{term}"

    logger.info "Finished searching"
  end

  def report_line(content_item)
    content_item_fields(content_item).join(", ")
  end

  def excluded?(content_item)
    exclude_types.include?(content_item.document_type)
  end

  def content_item_fields(content_item)
    [
      content_item.try(:title),
      "https://www.gov.uk#{content_item.try(:base_path)}",
      content_item.try(:publishing_app),
      content_item.expanded_links.dig(:organisations, 0, :title),
      content_item.try(:document_type),
      content_item.try(:content_id),
    ]
  end

  def content_items_matching(term)
    ContentItem.where('title ILIKE(?)', '%' + term + '%')
      .or(ContentItem.where(term_vector_jsonb_search_in('details'), term))
      .or(ContentItem.where(term_vector_jsonb_search_in('description'), term))
      .entries
  end

  def term_vector_jsonb_search_in(field)
    "jsonb_to_tsvector('english', " + field + ", '\"string\"') @@ plainto_tsquery('english', ?)"
  end

  def term_content_items
    @term_content_items ||= content_items_matching(term)
  end
end
