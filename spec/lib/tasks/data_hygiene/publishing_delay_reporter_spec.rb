require "rails_helper"
require "tasks/data_hygiene/publishing_delay_reporter"

describe Tasks::DataHygiene::PublishingDelayReporter do
  before(:each) do
    allow(GovukStatsd).to receive(:gauge)
  end

  it "reports nothing if no documents have been published recently" do
    expect(GovukStatsd).not_to receive(:gauge)

    described_class.new.report
  end

  it "reports mean publishing delay for recent scheduled publishings" do
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

  it "reports 95th percentile of publishing delays" do
    now = Time.new(2018, 3, 1, 10, 0)
    Timecop.freeze(now) do
      ScheduledPublishingLogEntry.create(scheduled_publication_time: now - 30.minutes)
      ScheduledPublishingLogEntry.create(scheduled_publication_time: now - 45.minutes)
      ScheduledPublishingLogEntry.create(scheduled_publication_time: now - 1.minute)
      ScheduledPublishingLogEntry.create(scheduled_publication_time: now - 15.minutes)
    end

    expect(GovukStatsd).to receive(:gauge).with("scheduled_publishing.aggregate.95_percentile_ms", 45.minutes.in_milliseconds)

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

describe Tasks::DataHygiene::PublishingDelayReporter::Stats do
  describe "#mean" do
    it "calculates the mean of a single value" do
      expect(described_class.mean([4])).to eq(4)
    end

    it "calculates the mean of multiple values" do
      expect(described_class.mean([1, 5, 3, 2, 10])).to eq(4.2)
    end

    it "rejects an empty array" do
      expect { described_class.mean([]) }.to raise_error(ArgumentError)
    end
  end

  describe "#percentile" do
    it "calculates the 0th percentile" do
      expect(described_class.percentile([3, 2, 8], 0)).to eq(2)
    end

    it "calculates the 100th percentile" do
      expect(described_class.percentile([4, 4, 5], 100)).to eq(5)
    end

    it "calculates the 95th percentile" do
      expect(described_class.percentile([12, 1, 5], 95)).to eq(12)
    end

    it "rejects an empty array" do
      expect { described_class.percentile([], 50) }.to raise_error(ArgumentError)
    end
  end
end
