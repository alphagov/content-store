require "rails_helper"

describe "submitting gone items to the content store", type: :request do
  context "creating a new gone item" do
    before(:each) do
      @data = {
        "base_path" => "/dodo-sanctuary",
        "schema_name" => "gone",
        "document_type" => "gone",
        "publishing_app" => "publisher",
        "payload_version" => "1",
        "routes" => [
          { "path" => "/dodo-sanctuary", "type" => "prefix" },
          { "path" => "/dodo-sanctuary.json", "type" => "exact" },
        ],
      }

      put_json "/content/dodo-sanctuary", @data
    end

    it "responds with a CREATED status" do
      expect(response).to have_http_status(:created)
    end

    it "creates the content item" do
      item = ContentItem.where(base_path: "/dodo-sanctuary").first
      expect(item).to be
      expect(item.schema_name).to eq("gone")
      expect(item.routes_and_redirects).to match_array([
        have_attributes(path: "/dodo-sanctuary", match_type: "prefix"),
        have_attributes(path: "/dodo-sanctuary.json", match_type: "exact"),
      ])
    end

    it "registers gone routes for the item" do
      assert_gone_routes_registered([["/dodo-sanctuary", "prefix"], ["/dodo-sanctuary.json", "exact"]])
    end
  end
end
