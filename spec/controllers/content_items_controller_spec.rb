require "rails_helper"

RSpec.describe ContentItemsController, type: :controller do
  describe "show" do
    let(:validator) { double(:validator) }

    before do
      FactoryGirl.create(:content_item, base_path: "/vat-rates")
    end

    it "validates against frontend schemas" do
      expect(SchemaValidator).to receive(:new)
        .with(type: :schema).and_return(validator)
      expect(validator).to receive(:validate)
        .with(hash_including("base_path" => "/vat-rates"))

      get :show, base_path_without_root: "vat-rates"
    end
  end
end
