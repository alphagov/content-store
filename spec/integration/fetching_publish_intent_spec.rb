require "rails_helper"

describe "Fetching a content item with a publish intent", type: :request do
  let(:content_item) { create(:content_item, public_updated_at: 30.minutes.ago) }

  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      create(:publish_intent, base_path: content_item.base_path, publish_time: 5.minutes.ago)
      get "/content/#{content_item.base_path}"

      expect(response).to be_successful
    end
  end

  context "a publish intent long in the past" do
    before(:each) do
      create(:publish_intent, base_path: content_item.base_path, publish_time: 5.minutes.ago)
      get "/content/#{content_item.base_path}"
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
      get "/content/#{content_item.base_path}"
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
      get "/content/#{content_item.base_path}"
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
      get "/content/#{content_item.base_path}"
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

  context "a publish intent for access limited content" do
    let(:content_item) { create(:access_limited_content_item, :by_user_id) }

    before(:each) do
      Timecop.freeze
      create(:publish_intent, base_path: content_item.base_path, publish_time: 5.minutes.from_now)
      get "/content/#{content_item.base_path}",
          headers: { "X-Govuk-Authenticated-User": content_item.access_limited["users"].first }
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(present(content_item))
    end

    it "sets cache headers to to the minimum ttl" do
      expect(cache_control["max-age"]).to eq(Rails.application.config.minimum_ttl.to_s)
    end

    it "sets a cache-control directive of private" do
      expect(cache_control["private"]).to eq(true)
    end
  end

  context "a publish intent for content accessed by auth_bypass_id" do
    let(:auth_bypass_id) { SecureRandom.uuid }
    let(:content_item) { create(:content_item, auth_bypass_ids: [auth_bypass_id]) }

    before(:each) do
      Timecop.freeze
      create(:publish_intent, base_path: content_item.base_path, publish_time: 5.minutes.from_now)
      get "/content/#{content_item.base_path}",
          headers: { "Govuk-Auth-Bypass-Id" => auth_bypass_id }
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(present(content_item))
    end

    it "sets cache headers to to the minimum ttl" do
      expect(cache_control["max-age"]).to eq(Rails.application.config.minimum_ttl.to_s)
    end

    it "sets a cache-control directive of private" do
      expect(cache_control["private"]).to eq(true)
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
