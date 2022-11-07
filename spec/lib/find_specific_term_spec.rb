require "rails_helper"

describe FindSpecificTerm do
  describe ".call" do
    let(:term) { "Test Content" }

    before do
      create(
        :content_item,
        document_type: "test",
        title: "Test Content",
        base_path: "/specific-term-test-content",
      )
    end

    it "finds 1 relevant content item" do
      expect(Rails.logger).to receive(:info).with("Searching for #{term}...")

      expect(Rails.logger).to receive(:info).with("Title,URL,Publishing application,Tagged organisation,Format,Content ID")

      expect(Rails.logger).to receive(:info).with("Found 1 items containing #{term}")

      expect(Rails.logger).to receive(:info).with("Test Content, https://www.gov.uk/specific-term-test-content, publisher, , test, ")

      expect(Rails.logger).to receive(:info).with("Finished searching")

      FindSpecificTerm.call(term)
    end

    it "does not find content item if document type is excluded" do
      create(
        :content_item,
        document_type: "other",
        title: "Test Content 2",
        base_path: "/specific-term-test-content-2",
      )

      expect(Rails.logger).to receive(:info).with("Searching for #{term}...")

      expect(Rails.logger).to receive(:info).with("Title,URL,Publishing application,Tagged organisation,Format,Content ID")

      expect(Rails.logger).to receive(:info).with("Found 1 items containing #{term}")

      expect(Rails.logger).to_not receive(:info).with("Test Content, https://www.gov.uk/specific-term-test-content, publisher, , test, ")
      expect(Rails.logger).to receive(:info).with("Test Content 2, https://www.gov.uk/specific-term-test-content-2, publisher, , other, ")

      expect(Rails.logger).to receive(:info).with("Finished searching")

      FindSpecificTerm.call(term, %w[test])
    end
  end
end
