require "rails_helper"

describe PublicationDelayReport do
  describe ".call" do
    subject { described_class.call($stdout) }

    context "with a delayed publication a day ago" do
      before do
        create(
          :content_item,
          document_type: "test",
          publishing_scheduled_at: 1.day.ago,
          scheduled_publishing_delay_seconds: 10,
        )
      end

      it "should include the publication in the CSV file" do
        expect { subject }.to output(/test/).to_stdout
      end
    end

    context "with a delayed publication a month ago" do
      before do
        create(
          :content_item,
          document_type: "test",
          publishing_scheduled_at: 30.days.ago,
          scheduled_publishing_delay_seconds: 10,
        )
      end

      it "should not include the publication in the CSV file" do
        expect { subject }.to_not output(/test/).to_stdout
      end
    end
  end
end
