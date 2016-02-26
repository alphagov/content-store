require "rails_helper"
require "tasks/data_hygiene/duplicate_report"

describe Tasks::DataHygiene::DuplicateReport do
  let(:fake_stdout) { StringIO.new }
  let(:fake_csv) { StringIO.new }

  before do
    @real_stdout = $stdout
    $stdout = fake_stdout
    allow(CSV).to receive(:open).and_return(fake_csv)
  end

  after { $stdout = @real_stdout }

  describe "#full" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id)
      create(:content_item, content_id: content_item.content_id)

      subject.full

      fake_stdout.rewind
      output = fake_stdout.read
      expect(output).to match(/duplicates: 2/)
    end
  end

  describe "#scoped_to(locale:)" do
    it "runs without issue" do
      content_item = create(:content_item_with_content_id, locale: 'en')
      create(:content_item, content_id: content_item.content_id, locale: 'en')
      create(:content_item, content_id: content_item.content_id, locale: 'fr')

      subject.scoped_to(locale: 'en')
      fake_stdout.rewind
      output = fake_stdout.read
      expect(output).to match(/duplicates: 3/)
      expect(output).to match(/duplicates_for_locale: 2/)
    end
  end
end
