require "csv"

class FindSpecificTerm
  attr_reader :term

  CSV_HEADERS = ["Title", "URL", "Publishing application", "Tagged organisation", "Format", "Content ID"].freeze

  def initialize(term)
    @term = term
  end

  def call
    write_csv
  end

  def self.call(*args)
    new(*args).call
  end

  def csv_rows(term)
    content_items = content_items(/#{term}/)
    content_items.map{ |content_item| csv_row(content_item) }
  end

private

  def write_csv
    CSV.open(Rails.root.join("tmp/search_term_content_items.csv"), "wb") do |csv|
      csv << CSV_HEADERS

      logger.info "Searching for #{term}..."

      csv_rows(term).each{ |csv_row| csv << csv_row }

      logger.info "Found #{term_content_items.count} items containing #{term}"
    end

    logger.info "Finished searching"
    # There's a subtle bug with RuboCop regexp where it thinks this
    # format of interpolated `Rails.root.join` is incorrect.
    logger.info "CSV file at #{Rails.root.join('tmp/search_term_content_items.csv')}"

    logger.info File.read(Rails.root.join("tmp/search_term_content_items.csv"))
  end

  def csv_row(content_item)
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
