class ScheduledPublishingLogEntry < ApplicationRecord

  before_save do |document|
    document.delay_in_milliseconds = set_delay_in_milliseconds
  end

private

  def set_delay_in_milliseconds
    ((Time.zone.now - scheduled_publication_time) * 1000.0).to_i
  end
end
