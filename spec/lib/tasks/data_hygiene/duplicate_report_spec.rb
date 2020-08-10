require "rails_helper"

describe Tasks::DataHygiene::DuplicateReport do
  let(:fake_csv) { StringIO.new }

  before do
    allow(CSV).to receive(:open).and_return(fake_csv)
  end

  describe "#full" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id)
      create(:content_item, content_id: content_item.content_id)

      expect(Rails.logger).to receive(:info).with("Fetching content items for duplicated content ids...")
      expect(Rails.logger).to receive(:info).with("Writing content items to csv...")
      expect(Rails.logger).to receive(:info).with("~~~~~~~~~\n Summary \n~~~~~~~~~\n")
      expect(Rails.logger).to receive(:info).with("blank_content_ids: 0")
      expect(Rails.logger).to receive(:info).with("duplicates: 2")

      subject.full
    end
  end

  describe "#scoped_to(locale:)" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id, locale: "en")
      create(:content_item, content_id: content_item.content_id, locale: "en")
      create(:content_item, content_id: content_item.content_id, locale: "fr")

      expect(Rails.logger).to receive(:info).with("Fetching content items for duplicated content ids...")
      expect(Rails.logger).to receive(:info).with("Writing content items to csv...")
      expect(Rails.logger).to receive(:info).with("~~~~~~~~~\n Summary \n~~~~~~~~~\n")
      expect(Rails.logger).to receive(:info).with("blank_content_ids: 0")
      expect(Rails.logger).to receive(:info).with("duplicates: 3")
      expect(Rails.logger).to receive(:info).with("duplicates_for_locale: 2")

      subject.scoped_to(locale: "en")
    end
  end
end
