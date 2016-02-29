require 'rails_helper'

RSpec.describe "Deleting a content item", type: :request do
  let(:base_path) { "/vat-rates" }

  context "when the content item exists" do
    before do
      FactoryGirl.create(:content_item, base_path: base_path)
    end

    it "deletes the content item" do
      delete "/content/vat-rates"

      expect(ContentItem.where(base_path: base_path).count).to eq(0)
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
