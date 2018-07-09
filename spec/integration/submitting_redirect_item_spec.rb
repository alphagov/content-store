require 'rails_helper'

describe "submitting redirect items to the content store", type: :request do
  before :each do
    @data = {
      "base_path" => "/crb-checks",
      "format" => "redirect",
      "schema_name" => "redirect",
      "document_type" => "redirect",
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "publishing_app" => "publisher",
      "redirects" => [
        { "path" => "/crb-checks", "type" => "prefix", "destination" => "/dbs-checks" },
        { "path" => "/crb-checks.json", "type" => "exact", "destination" => "/api/content/dbs-checks" }
      ],
      "payload_version" => 1,
    }
  end

  context "creating a new redirect item" do
    before(:each) do
      put_json "/content/crb-checks", @data
    end

    it "responds with a CREATED status" do
      expect(response.status).to eq(201)
    end

    it "creates the content item" do
      item = ContentItem.where(base_path: "/crb-checks").first
      expect(item).to be
      expect(item.format).to eq("redirect")
      expect(item.public_updated_at).to eq(Time.zone.parse("2014-05-14T13:00:06Z"))
      expect(item.updated_at).to be_within(10.seconds).of(Time.zone.now)
    end

    it "registers redirect routes for the item" do
      assert_redirect_routes_registered([['/crb-checks', 'prefix', '/dbs-checks'], ['/crb-checks.json', 'exact', '/api/content/dbs-checks']])
    end
  end

  context "replacing an existing item with a redirect" do
    before(:each) do
      @item = create(
        :content_item,
        base_path: "/crb-checks",
        public_updated_at: Time.zone.parse("2014-03-12T14:53:54Z"),
        details: { "foo" => "bar" }
      )
      WebMock::RequestRegistry.instance.reset! # Clear out any requests made by factory creation.
      put_json "/content/crb-checks", @data
    end

    it "responds with an OK status" do
      expect(response.status).to eq(200)
    end

    it "updates the content item" do
      @item.reload
      expect(@item.format).to eq("redirect")
      expect(@item.title).to be_nil
      expect(@item.public_updated_at).to eq(Time.zone.parse("2014-05-14T13:00:06Z"))
      expect(@item.updated_at).to be_within(10.seconds).of(Time.zone.now)
      expect(@item.details).to eq({})
    end

    it "updates routes for the content item" do
      assert_redirect_routes_registered([['/crb-checks', 'prefix', '/dbs-checks'], ['/crb-checks.json', 'exact', '/api/content/dbs-checks']])
    end
  end
end
