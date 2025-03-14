require "rails_helper"

RSpec.describe "Deleting a content item", type: :request do
  let(:base_path) { "/vat-rates" }

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      delete "/content/vat-rates"

      expect(response).to be_unauthorized
    end
  end

  context "when the content item exists" do
    before do
      FactoryBot.create(:content_item, base_path:)
    end

    it "deletes the content item" do
      delete "/content/vat-rates"

      expect(ContentItem.where(base_path:).count).to eq(0)
    end

    it "returns a 200" do
      delete "/content/vat-rates"

      expect(response.status).to eq(200)
    end
  end

  context "when the content item doesn't exist" do
    it "returns a 404" do
      delete "/content/vat-rates"

      expect(response.status).to eq(404)
    end
  end
end
