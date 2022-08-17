require "csv"

class FindSpecificTerm
  attr_reader :term

  CONTENT_ITEM_HEADERS = ["Title", "URL", "Publishing application", "Tagged organisation", "Format", "Content ID"].freeze

  def initialize(term)
    @term = term
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

    term_content_items = content_items(/#{term}/)

    logger.info CONTENT_ITEM_HEADERS.join(",")

    term_content_items.each do |content_item|
      logger.info content_item_fields(content_item).join(", ")
    end

    logger.info "Found #{term_content_items.count} items containing #{term}"

    logger.info "Finished searching"
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

  def content_items(term)
    ContentItem.or('title': term)
      .or('details.body': term)
      .or('description': term)
      .or('description.content': term)
      .or('details.body.content': term)
      .or('details.parts.body': term)
      .or('details.parts.body.content': term)
      .or('details.nodes.title': term)
      .or('details.nodes.options.label': term)
      .or('details.nodes.body': term)
      .or('details.nodes.body.content': term)
      .or('details.email_addresses.email': term)
      .or('details.introductory_paragraph': term)
      .or('details.introductory_paragraph.content': term)
      .or('details.more_information': term)
      .or('details.more_information.content': term)
      .or('details.more_info_contact_form': term)
      .or('details.more_info_email_address': term).entries
  end
end
