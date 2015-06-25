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
      expect(response.headers["Expires"]).to eq(default_ttl.from_now.httpdate)
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
      expect(response.headers["Expires"]).to eq(default_ttl.from_now.httpdate)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end
end
