require "rails_helper"

describe ScheduledPublishingLogEntry do
  describe "when created" do
    it "sets the delay" do
      publication_time = Time.now
      allow(Time).to receive(:now)
        .and_return(publication_time + 20)
      log_entry = ScheduledPublishingLogEntry.create(
        base_path: "/booyah",
        document_type: "stats",
        scheduled_publication_time: publication_time
      )

      expect(log_entry.delay_in_milliseconds).to be_within(1).of(20000)
    end
  end

  describe "find latest by path" do
    it "returns nil if there are no log entries for the given path" do
      log_entry = ScheduledPublishingLogEntry.latest_with_path("/some_page")
      expect(log_entry).to be_nil
    end

    it "returns a single log entry" do
      expected_log_entry = ScheduledPublishingLogEntry.create(
        base_path: "/a_scheduled_page",
        scheduled_publication_time: Time.now,
      )
      log_entry = ScheduledPublishingLogEntry.latest_with_path("/a_scheduled_page")
      expect(log_entry).to eq(expected_log_entry)
    end

    it "returns the log entry for the most recent publishing" do
      ScheduledPublishingLogEntry.create(
        base_path: "/some_path",
        scheduled_publication_time: Time.new(2015, 5, 1),
      )
      ScheduledPublishingLogEntry.create(
        base_path: "/some_path",
        scheduled_publication_time: Time.new(2018, 3, 20),
      )
      ScheduledPublishingLogEntry.create(
        base_path: "/some_path",
        scheduled_publication_time: Time.new(2017, 12, 31),
      )
      log_entry = ScheduledPublishingLogEntry.latest_with_path("/some_path")
      expect(log_entry.scheduled_publication_time).to eq(Time.new(2018, 3, 20))
    end
  end
end
