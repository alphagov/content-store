class Tasks::DataHygiene::PublishingDelayReporter
  STATISTICS_TYPES = %w[
    national_statistics
    official_statistics
    national_statistics_announcement
    official_statistics_announcement
  ].freeze

  def report
    now = Time.zone.now

    log_entries = ScheduledPublishingLogEntry.where(created_at: (now - 1.day)..now)
    stats_reporter = StatsReporter.new(log_entries)

    STATISTICS_TYPES.each do |stats_type|
      stats_reporter.report(stats_type) { |entry| entry.document_type == stats_type }
    end

    stats_reporter.report("other_document_types") { |entry| STATISTICS_TYPES.exclude?(entry.document_type) }

    stats_reporter.report("all_document_types")
  end

  class StatsReporter
    attr_reader :log_entries

    def initialize(log_entries)
      @log_entries = log_entries
    end

    def report(namespace, &filter)
      delays = log_entries.select(&filter).map(&:delay_in_milliseconds)
      return if delays.empty?

      GovukStatsd.gauge("scheduled_publishing.aggregate.#{namespace}.mean_ms", Stats.mean(delays))
      GovukStatsd.gauge("scheduled_publishing.aggregate.#{namespace}.95_percentile_ms", Stats.percentile(delays, 95))
    end
  end
end

class Tasks::DataHygiene::PublishingDelayReporter::Stats
  def self.mean(values)
    raise ArgumentError, "Cannot calculate the mean of an empty array" if values.empty?

    values.sum / values.size.to_f
  end

  def self.percentile(values, percentile)
    raise ArgumentError, "Cannot calculate percentile #{percentile} of an empty array" if values.empty?

    ordinal = (values.length * percentile.to_f / 100).ceil
    index = [0, ordinal - 1].max
    values.sort[index]
  end
end
