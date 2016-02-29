require "rails_helper"
require "tasks/data_hygiene/content_item_deduplicator"

describe Tasks::DataHygiene::ContentItemDeduplicator do
  let(:fake_stdout) { StringIO.new }

  before do
    @real_stdout = $stdout
    $stdout = fake_stdout
  end

  after { $stdout = @real_stdout }

  describe "#deduplicate" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id, locale: 'cy')
      create(:content_item, content_id: content_item.content_id, locale: 'cy')
      create(:content_item, content_id: content_item.content_id, locale: 'en')

      expect { subject.deduplicate }.to change(ContentItem, :count).by(-1)

      fake_stdout.rewind
      output = fake_stdout.read
      expect(output).to match(/2 duplicates found/)
      expect(output).to match(/1 records were removed/)
    end
  end

  describe "#report_duplicates" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id, locale: 'en')
      create(:content_item, content_id: content_item.content_id, locale: 'en')
      create(:content_item, content_id: content_item.content_id, locale: 'fr')

      expect { subject.report_duplicates }.not_to change(ContentItem, :count)

      fake_stdout.rewind
      output = fake_stdout.read

      expect(output).to match(/2 duplicates found/)
      expect(output).to match(/1 records would be removed/)
    end
  end
end
