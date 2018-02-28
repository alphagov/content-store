require "rails_helper"
require "tasks/data_hygiene/publishing_delay_reporter"

describe Tasks::DataHygiene::PublishingDelayReporter do
  it "reports nothing if no documents have been published recently" do
    expect(GovukStatsd).not_to receive(:gauge)

    described_class.new.report
  end

  it "reports publishing delays for recent scheduled publishings" do
    Timecop.freeze(Time.new(2018, 3, 1, 9, 32)) do
      ScheduledPublishingLogEntry.create(scheduled_publication_time: Time.new(2018, 3, 1, 9, 30))
    end

    Timecop.freeze(Time.new(2018, 3, 1, 11, 4)) do
      ScheduledPublishingLogEntry.create(scheduled_publication_time: Time.new(2018, 3, 1, 11, 0))
    end

    expected_mean_delay_ms = 180_000 # Mean of 2 and 4 minutes = 180,000 ms
    expect(GovukStatsd).to receive(:gauge).with("scheduled_publishing.aggregate.mean_ms", expected_mean_delay_ms)

    Timecop.freeze(Time.new(2018, 3, 1, 12, 0)) do
      described_class.new.report
    end
  end

  it "limits report to documents published in the past 24 hours" do
    old_scheduled_publishing = Time.new(2018, 3, 1, 12, 30)
    Timecop.freeze(old_scheduled_publishing + 15.minutes) do
      ScheduledPublishingLogEntry.create(scheduled_publication_time: old_scheduled_publishing)
    end

    recent_scheduled_publishing = Time.new(2018, 3, 5, 9, 30)
    recent_publishing_delay = 1.hour
    Timecop.freeze(recent_scheduled_publishing + recent_publishing_delay) do
      ScheduledPublishingLogEntry.create(scheduled_publication_time: recent_scheduled_publishing)
    end

    expect(GovukStatsd).to receive(:gauge).with("scheduled_publishing.aggregate.mean_ms", recent_publishing_delay.in_milliseconds)

    Timecop.freeze(Time.new(2018, 3, 6, 9, 45)) do
      described_class.new.report
    end
  end
end
