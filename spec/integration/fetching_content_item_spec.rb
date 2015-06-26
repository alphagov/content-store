require 'rails_helper'

describe "Fetching content items", :type => :request do
  let(:content_item) { create(:content_item) }

  context "an existing content item" do
    before(:each) { get_content content_item }

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(public_presentation(content_item))
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end


  context "a content item with a non-ASCII base_path" do
    let(:content_item) { create(:content_item, base_path: URI.encode('/news/בוט לאינד')) }

    before(:each) { get_content content_item }

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(public_presentation(content_item))
    end
  end


  context "a non-existent content item" do
    before(:each) { get "/content/does/not/exist" }

    it "returns a 404 Not Found response" do
      expect(response.status).to eq(404)
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end


  context "a content item with linked items" do
    let(:content_item) { create(:content_item, links: { 'related' => [linked_item.content_id] }) }
    let(:linked_item) { create(:content_item, :with_content_id) }

    before(:each) { get_content content_item }

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "corrrectly expands linked items with internal API URLs" do
      data = JSON.parse(response.body)

      expect(data["links"]["related"].first["api_url"]).to eq("http://www.example.com/content#{linked_item.base_path}")
    end
  end
end
