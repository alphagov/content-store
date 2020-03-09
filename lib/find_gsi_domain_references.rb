require "csv"

class FindGsiDomainReferences
  CSV_HEADERS = ["Title", "URL", "Publishing application", "Publishing organisation", "Format", "Domain", "Content ID"].freeze

  def call
    write_csv
  end

  def self.call(*args)
    new(*args).call
  end

  private_class_method :new

private

  def write_csv
    CSV.open(Rails.root.join("tmp/gsi_domain_content_items.csv"), "wb") do |csv|
      csv << CSV_HEADERS

      domains = %w(gsi gse gcsx gsx)

      domains.each do |domain|
        puts "Searching for #{domain}.gov.uk..."

        domain_content_items = content_items(/#{domain}\.gov\.uk/)

        domain_content_items.each do |content_item|
          csv << csv_row(content_item, domain)
        end

        puts "Found #{domain_content_items.count} items containing #{domain}.gov.uk"
      end
    end

    puts "Finished searching"
    # There's a subtle bug with RuboCop regexp where it thinks this
    # format of interpolated `Rails.root.join` is incorrect.
    # rubocop:disable Rails/FilePath
    puts "CSV file at #{Rails.root.join('tmp/gsi_domain_content_items.csv')}"
    # rubocop:enable Rails/FilePath
  end

  def csv_row(content_item, domain)
    [
      content_item.try(:title),
      "https://www.gov.uk#{content_item.try(:base_path)}",
      content_item.try(:publishing_app),
      content_item.expanded_links.dig(:organisations, 0, :title),
      content_item.try(:document_type),
      domain,
      content_item.try(:content_id),
    ]
  end

  def content_items(domain)
    ContentItem.or('details.body': domain)
      .or('details.body.content': domain)
      .or('details.parts.body': domain)
      .or('details.parts.body.content': domain)
      .or('details.nodes.body': domain)
      .or('details.nodes.body.content': domain)
      .or('details.email_addresses.email': domain)
      .or('details.introductory_paragraph': domain)
      .or('details.introductory_paragraph.content': domain)
      .or('details.more_information': domain)
      .or('details.more_information.content': domain)
      .or('details.more_info_contact_form': domain)
      .or('details.more_info_email_address': domain).entries
  end
end
