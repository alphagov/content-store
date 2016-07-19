require 'rails_helper'

describe "Fetching an access-limited content item", type: :request do
  let(:access_limited_content_item) { create(:access_limited_content_item) }
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
        {}, { 'X-Govuk-Authenticated-User' => authorised_user_uid }
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
        {}, { 'X-Govuk-Authenticated-User' => 'unauthorised-user' }

      json = JSON.parse(response.body)

      expect(response.status).to eq(403)
      expect(json["errors"]["type"]).to eq("access_forbidden")
      expect(json["errors"]["code"]).to eq("403")
    end
  end
end
