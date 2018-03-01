class ScheduledPublishingLogEntry
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  field :base_path, type: String
  field :document_type, type: String
  field :scheduled_publication_time, type: DateTime
  field :delay_in_milliseconds

  before_save do |document|
    document.delay_in_milliseconds = set_delay_in_milliseconds
  end

  def self.latest_with_path(base_path)
    ScheduledPublishingLogEntry.where(base_path: base_path)
      .order_by(scheduled_publication_time: "desc")
      .first
  end

private

  def set_delay_in_milliseconds
    ((Time.now - scheduled_publication_time) * 1000.0).to_i
  end
end
