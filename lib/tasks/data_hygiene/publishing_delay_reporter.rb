class Tasks::DataHygiene::PublishingDelayReporter
  def report
    now = Time.zone.now

    log_entries = ScheduledPublishingLogEntry.where(created_at: (now - 1.day)..now)
    delays = log_entries.map(&:delay_in_milliseconds)

    unless delays.empty?
      GovukStatsd.gauge("scheduled_publishing.aggregate.mean_ms", mean(delays))
    end
  end

private

  def mean(delays)
    delays.sum / delays.size.to_f
  end
end
