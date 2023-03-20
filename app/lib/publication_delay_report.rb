class PublicationDelayReport
  def initialize(file)
    @file = file
  end

  def call
    write_csv
  end

  def self.call(*args)
    new(*args).call
  end

  private_class_method :new

private

  attr_reader :file

  MINIMUM_DELAY_SECONDS = 1
  CSV_HEADERS = ["URL", "Document Type", "Scheduled Time", "Delay (seconds)"].freeze

  def write_csv
    CSV.instance(file, headers: CSV_HEADERS, write_headers: true) do |csv|
      delayed_content_items.each do |content_item|
        csv << csv_row(content_item)
      end
    end
  end

  def csv_row(content_item)
    [
      content_item.base_path,
      content_item.document_type,
      content_item.publishing_scheduled_at,
      content_item.scheduled_publishing_delay_seconds,
    ]
  end

  def delayed_content_items
    ContentItem
      .where("scheduled_publishing_delay_seconds > ?", MINIMUM_DELAY_SECONDS)
      .where("publishing_scheduled_at > ?", 7.days.ago)
      .order(publishing_scheduled_at: :asc)
  end
end
