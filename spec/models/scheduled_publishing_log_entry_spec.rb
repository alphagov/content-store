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
        scheduled_publication_time: publication_time,
      )

      expect(log_entry.delay_in_milliseconds).to be_within(1).of(20000)
    end
  end
end
