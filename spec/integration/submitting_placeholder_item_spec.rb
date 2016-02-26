require 'rails_helper'

describe "submitting placeholder items to the content store", type: :request do
  before :each do
    @data = {
      "base_path" => "/vat-rates",
      "content_id" => SecureRandom.uuid,
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "placeholder",
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "transmitted_at" => "2",
      "payload_version" => "1",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "routes" => [
        { "path" => "/vat-rates", "type" => 'exact' }
      ],
    }
  end

  describe "creating a new content item" do
    it "creates the content item" do
      put_json "/content/vat-rates", @data
      item = ContentItem.where(base_path: "/vat-rates").first
      expect(item).to be
      expect(item.title).to eq("VAT rates")
      expect(item.description).to eq("Current VAT rates")
      expect(item.format).to eq("placeholder")
    end

    it "does not register routes for the content item" do
      put_json "/content/vat-rates", @data
      refute_routes_registered("frontend", [['/vat-rates', 'exact']])
    end
  end

  context 'updating an existing content item' do
    before(:each) do
      Timecop.travel(30.minutes.ago) do
        @item = create(:content_item,
                     title: "Original title",
                     base_path: "/vat-rates",
                     need_ids: ["100321"],
                     public_updated_at: Time.zone.parse("2014-03-12T14:53:54Z"),
                     details: { "foo" => "bar" }
                      )
      end
      WebMock::RequestRegistry.instance.reset! # Clear out any requests made by factory creation.
    end

    it "updates the content item" do
      put_json "/content/vat-rates", @data
      @item.reload
      expect(@item.title).to eq("VAT rates")
      expect(@item.format).to eq("placeholder")
    end

    it "does not update routes for the content item" do
      @data["routes"] << { "path" => "/vat-rates.json", "type" => 'exact' }
      put_json "/content/vat-rates", @data
      refute_routes_registered("frontend", [['/vat-rates', 'exact']])
    end
  end

  context "an item with a format prefixed with 'placeholder_'" do
    before :each do
      @data["format"] = "placeholder_answer"
    end

    it "creates the content item" do
      put_json "/content/vat-rates", @data
      item = ContentItem.where(base_path: "/vat-rates").first
      expect(item).to be
      expect(item.title).to eq("VAT rates")
      expect(item.description).to eq("Current VAT rates")
      expect(item.format).to eq("placeholder_answer")
    end

    it "does not register routes for the content item" do
      put_json "/content/vat-rates", @data
      refute_routes_registered("frontend", [['/vat-rates', 'exact']])
    end
  end
end
