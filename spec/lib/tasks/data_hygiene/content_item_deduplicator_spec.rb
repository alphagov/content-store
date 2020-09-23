require "rails_helper"

describe DataHygiene::ContentItemDeduplicator do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to("2020-02-27".in_time_zone) { example.run }
  end

  describe "#deduplicate" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id, locale: "cy")
      content_item2 = create(:content_item, content_id: content_item.content_id, locale: "cy")
      create(:content_item, content_id: content_item.content_id, locale: "en")

      expect(Rails.logger).to receive(:info).with("These duplicates were destroyed...")
      expect(Rails.logger).to receive(:info).with("#{content_item.content_id},cy,2020-02-27 00:00:00 UTC,#{content_item.base_path}")
      expect(Rails.logger).to receive(:info).twice.with("-----------------------------------------------------------------")
      expect(Rails.logger).to receive(:info).with("These records were preserved...")
      expect(Rails.logger).to receive(:info).with("#{content_item.content_id},cy,2020-02-27 00:00:00 UTC,#{content_item2.base_path}")
      expect(Rails.logger).to receive(:info).with("2 duplicates found.")
      expect(Rails.logger).to receive(:info).with("1 records were removed.")
      expect(Rails.logger).to receive(:info).with("1 records were preserved.")

      expect { subject.deduplicate }.to change(ContentItem, :count).by(-1)
    end
  end

  describe "#report_duplicates" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id, locale: "en")
      content_item2 = create(:content_item, content_id: content_item.content_id, locale: "en")
      create(:content_item, content_id: content_item.content_id, locale: "fr")

      expect(Rails.logger).to receive(:info).with("These duplicates would be destroyed...")
      expect(Rails.logger).to receive(:info).with("#{content_item.content_id},en,2020-02-27 00:00:00 UTC,#{content_item.base_path}")
      expect(Rails.logger).to receive(:info).twice.with("-----------------------------------------------------------------")
      expect(Rails.logger).to receive(:info).with("These records would be preserved...")
      expect(Rails.logger).to receive(:info).with("#{content_item.content_id},en,2020-02-27 00:00:00 UTC,#{content_item2.base_path}")
      expect(Rails.logger).to receive(:info).with("2 duplicates found.")
      expect(Rails.logger).to receive(:info).with("1 records would be removed.")
      expect(Rails.logger).to receive(:info).with("1 records would be preserved.")

      expect { subject.report_duplicates }.not_to change(ContentItem, :count)
    end
  end
end
