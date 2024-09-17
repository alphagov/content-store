require "rails_helper"

describe "find a route", type: :request do
  context "when route is found" do
    let(:route) { create(:route) } # Assuming you have a factory for routes

    before do
      get "/routes", params: { path: route.path }
    end

    it "returns a successful response" do
      expect(response).to have_http_status(:success)
    end

    it "returns the correct route json" do
      expected_json = {
        backend: route.backend,
        destination: route.destination,
        segments_mode: route.segments_mode,
        path: route.path,
        match_type: route.match_type,
      }.to_json

      expect(response.body).to eq(expected_json)
    end
  end

  context "when route is not found" do
    before do
      allow(Route).to receive(:find_matching_route).and_return(nil)
      get "/routes", params: { path: "non-existent-path" }
    end

    it "returns a not found response" do
      expect(response).to have_http_status(:not_found)
    end
  end
end
