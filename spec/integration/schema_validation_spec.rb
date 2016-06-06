require "rails_helper"

RSpec.describe "Schema validation", type: :request do
  context "when the content item is valid" do
    let!(:content_item) do
      FactoryGirl.create(:content_item_with_content_id,
        schema_name: "policy",
        format: "policy",
        details: {
          document_noun: "Policy",
          facets: [],
        },
        links: {
          organisations: [],
          related: [],
        }
      )
    end

    it "returns OK" do
      get_content(content_item)

      expect(response.status).to eq(200)
    end

    it "does not report an error to errbit" do
      expect(Airbrake).not_to receive(:notify_or_ignore)
      expect(Airbrake).not_to receive(:notify)

      get_content(content_item)
    end
  end

  context "when the content item is invalid" do
    let!(:content_item) do
      FactoryGirl.create(:content_item_with_content_id,
        schema_name: "policy",
        details: {},
      )
    end

    it "returns OK" do
      get_content(content_item)

      expect(response.status).to eq(200)
    end

    it "reports an error to errbit" do
      expect(Airbrake).to receive(:notify_or_ignore)

      get_content(content_item)
    end
  end
end
