require 'rails_helper'

describe "Fetching an access-limited by user-id content item", type: :request do
  let(:access_limited_content_item) { create(:access_limited_content_item, :by_user_id) }
  let(:authorised_user_uid) { access_limited_content_item.access_limited['users'].first }

  context "request without an authentication header" do
    it "returns a 403 (Forbidden) response" do
      get "/content/#{access_limited_content_item.base_path}"

      json = JSON.parse(response.body)

      expect(response.status).to eq(403)
      expect(json["errors"]["type"]).to eq("access_forbidden")
      expect(json["errors"]["code"]).to eq("403")
    end
  end

  context "request with an authorised user ID specified in the header" do
    before do
      get "/content/#{access_limited_content_item.base_path}",
        params: {}, headers: { 'X-Govuk-Authenticated-User' => authorised_user_uid }
    end

    it "returns the details for the requested item" do
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")

      data = JSON.parse(response.body)
      expect(data['title']).to eq(access_limited_content_item.title)
    end

    it "marks the cache-control as private" do
      expect(cache_control["private"]).to eq(true)
    end
  end

  context "request with an unauthorised user ID specified in the header" do
    it "returns a 403 (Forbidden) response" do
      get "/content/#{access_limited_content_item.base_path}",
        params: {}, headers: { 'X-Govuk-Authenticated-User' => 'unauthorised-user' }

      json = JSON.parse(response.body)

      expect(response.status).to eq(403)
      expect(json["errors"]["type"]).to eq("access_forbidden")
      expect(json["errors"]["code"]).to eq("403")
    end
  end

  context "with a fact check ID specified in the header" do
    let(:access_limited_content_item) { create(:access_limited_content_item, :by_fact_check_id) }
    let(:fact_check_id) { access_limited_content_item.access_limited["fact_check_ids"].first }

    before do
      get "/content/#{access_limited_content_item.base_path}",
        params: {}, headers: { 'Govuk-Fact-Check-Id' => fact_check_id }
    end

    it "marks the cache-control as private" do
      expect(cache_control["private"]).to eq(true)
    end

    context "if the fact check ID matches" do
      it "returns the requested item" do
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")

        data = JSON.parse(response.body)
        expect(data['title']).to eq(access_limited_content_item.title)
      end
    end

    context "if the fact check ID does not match" do
      let(:fact_check_id) { SecureRandom.uuid }
      it "returns a 403 Forbidden response" do
        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end
  end
end
