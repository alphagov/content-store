require 'rails_helper'

describe "Fetching a content item with a publish intent", type: :request do
  let(:content_item) { create(:content_item, public_updated_at: 30.minutes.ago) }

  context "a publish intent long in the past" do
    before(:each) do
      create(:publish_intent, base_path: content_item.base_path, publish_time: 5.minutes.ago)
      get_content content_item
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(present(content_item))
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end


  context "a publish intent that has newly passed" do
    before(:each) do
      create(:publish_intent, base_path: content_item.base_path, publish_time: 10.seconds.ago)
      get_content content_item
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(present(content_item))
    end

    it "sets cache headers to the minimum TTL" do
      expect(cache_control["max-age"]).to eq(Rails.application.config.minimum_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end


  context "a publish intent more than the default TTL away" do
    before(:each) do
      create(:publish_intent, base_path: content_item.base_path, publish_time: 40.minutes.from_now)
      get_content content_item
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(present(content_item))
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end


  context "a publish intent before the default TTL time" do
    before(:each) do
      Timecop.freeze
      create(:publish_intent, base_path: content_item.base_path, publish_time: 5.minutes.from_now)
      get_content content_item
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(present(content_item))
    end

    it "sets cache headers to expire when the publish intent is due" do
      expect(cache_control["max-age"]).to eq(5.minutes.to_i.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end
end

describe "Fetching a publish intent without a content item", type: :request do
  before(:each) do
    Timecop.freeze
    create(:publish_intent, base_path: "/some/future/thing", publish_time: 5.minutes.from_now)
    get "/content/some/future/thing"
  end

  it "returns a 404 Not Found response" do
    expect(response.status).to eq(404)
  end

  it "sets cache headers to expire according to the publish intent" do
    expect(cache_control["max-age"]).to eq(5.minutes.to_i.to_s)
  end

  it "sets a cache-control directive of public" do
    expect(cache_control["public"]).to eq(true)
  end
end
