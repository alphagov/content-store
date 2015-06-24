require 'rails_helper'

describe "Fetching an access-limited content item", :type => :request do
  let!(:access_limited_content_item) {
    create(:access_limited_content_item)
  }
  let(:authorised_user_id) { access_limited_content_item.access_limited['users'].first }

  context "request without an authentication header" do
    it "returns an 403 (Forbidden) response" do
      get "content/#{access_limited_content_item.base_path}"

      expect(response.status).to eq(403)
      data = JSON.parse(response.body)

      expect(response.body).to eq("{}")
    end
  end

  context "request with an authorised user id specified in the header" do
    it "returns the details for the requested item" do
      get "/content/#{access_limited_content_item.base_path}",
        {}, { 'X-Govuk-Authenticated-User' => authorised_user_id }

      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")

      data = JSON.parse(response.body)
      expect(data['title']).to eq(access_limited_content_item.title)
    end
  end
end
