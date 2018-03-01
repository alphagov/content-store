class Tasks::DataHygiene::PublishingDelayReporter
  def report
    now = Time.zone.now

    log_entries = ScheduledPublishingLogEntry.where(created_at: (now - 1.day)..now)
    delays = log_entries.map(&:delay_in_milliseconds)

    unless delays.empty?
      GovukStatsd.gauge("scheduled_publishing.aggregate.mean_ms", Stats.mean(delays))
      GovukStatsd.gauge("scheduled_publishing.aggregate.95_percentile_ms", Stats.percentile(delays, 95))
    end
  end
end

class Tasks::DataHygiene::PublishingDelayReporter::Stats
  def self.mean(values)
    raise ArgumentError.new("Cannot calculate the mean of an empty array") if values.empty?

    values.sum / values.size.to_f
  end

  def self.percentile(values, percentile)
    raise ArgumentError.new("Cannot calculate percentile #{percentile} of an empty array") if values.empty?

    ordinal = (values.length * percentile.to_f / 100).ceil
    index = [0, ordinal - 1].max
    values.sort[index]
  end
end
