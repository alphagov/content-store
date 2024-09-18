require "rails_helper"

describe Route, type: :model do
  describe "#find_matching_route" do
    let!(:route_exact) { create(:route, path: "/exact-path") }
    let!(:route_prefix) { create(:route, :publish_intent, path: "/prefix-path", match_type: "prefix") }
    let!(:route_redirect) { create(:route, :redirect, path: "/redirect-path") }
    let!(:route_gone) { create(:route, :gone, path: "/gone-path") }
    let!(:route_exact_over_prefix) { create(:route, path: "/exact-over-prefix") }
    let!(:route_prefix_with_exact) { create(:route, path: "/exact-over-prefix", match_type: "prefix") }
    let!(:route_longer_prefix) { create(:route, path: "/prefix-path/longer", match_type: "prefix") }

    it "returns the route with exact match" do
      result = Route.find_matching_route("/exact-path")
      expect(result).to eq(route_exact)
    end

    it "returns the route with prefix match" do
      result = Route.find_matching_route("/prefix-path/subpath")
      expect(result).to eq(route_prefix)
    end

    it "returns the route with redirect" do
      result = Route.find_matching_route("/redirect-path")
      expect(result).to eq(route_redirect)
    end

    it "returns the route with gone status" do
      result = Route.find_matching_route("/gone-path")
      expect(result).to eq(route_gone)
    end

    it "returns nil when no matching route is found" do
      result = Route.find_matching_route("/non-existent-path")
      expect(result).to be_nil
    end

    it "returns the exact match over prefix match" do
      result = Route.find_matching_route("/exact-over-prefix")
      expect(result).to eq(route_exact_over_prefix)
    end

    it "returns the longer prefix match" do
      result = Route.find_matching_route("/prefix-path/longer/subpath")
      expect(result).to eq(route_longer_prefix)
    end
  end

  describe "#backend" do
    context "when content_item is present" do
      it "returns 'gone' if content_item is gone" do
        route = create(:route, :gone)
        expect(route.backend).to eq("gone")
      end

      it "returns 'redirect' if content_item is a redirect" do
        route = create(:route, :redirect)
        expect(route.backend).to eq("redirect")
      end

      it "returns the rendering_app of the content_item if not gone or redirect" do
        route = create(:route)
        expect(route.backend).to eq("collections")
      end
    end

    context "when publish_intent is present and content_item is not" do
      it "returns the rendering_app of the publish_intent" do
        route = create(:route, :publish_intent)
        expect(route.backend).to eq("frontend")
      end
    end
  end

  describe "validations" do
    it "is valid with either content_item or publish_intent" do
      route_with_content_item = build(:route)
      route_with_publish_intent = build(:route, :publish_intent)

      expect(route_with_content_item).to be_valid
      expect(route_with_publish_intent).to be_valid
    end

    it "is invalid without both content_item and publish_intent" do
      route = build(:route, content_item: nil, publish_intent: nil)
      expect(route).not_to be_valid
      expect(route.errors[:base]).to include("A route must have either a content_item or a publish_intent")
    end
  end
end
