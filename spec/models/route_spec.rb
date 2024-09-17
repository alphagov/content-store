require "rails_helper"

describe Route, type: :model do
  describe "#find_matching_route" do
    let!(:content_item) { create(:content_item, rendering_app: "collections") }
    let!(:gone_content_item) { create(:content_item, schema_name: "gone", details: nil) }
    let!(:redirect_content_item) { create(:content_item, schema_name: "redirect") }
    let!(:publish_intent) { create(:publish_intent, rendering_app: "frontend") }
    let!(:route_exact) { create(:route, path: "/exact-path", match_type: "exact", content_item:) }
    let!(:route_prefix) { create(:route, path: "/prefix-path", match_type: "prefix", publish_intent:) }
    let!(:route_redirect) do
      create(
        :route,
        path: "/redirect-path",
        match_type: "exact",
        destination: "http://example.com",
        content_item: redirect_content_item,
      )
    end
    let!(:route_gone) { create(:route, path: "/gone-path", match_type: "exact", content_item: gone_content_item) }
    let!(:route_exact_over_prefix) { create(:route, path: "/exact-over-prefix", match_type: "exact", content_item:) }
    let!(:route_prefix_with_exact) { create(:route, path: "/exact-over-prefix", match_type: "prefix", content_item:) }
    let!(:route_longer_prefix) { create(:route, path: "/prefix-path/longer", match_type: "prefix", content_item:) }

    it "returns the route with exact match" do
      result = Route.find_matching_route("/exact-path")
      expect(result).to eq(route_exact)
      expect(result.backend).to eq("collections")
    end

    it "returns the route with prefix match" do
      result = Route.find_matching_route("/prefix-path/subpath")
      expect(result).to eq(route_prefix)
      expect(result.backend).to eq("frontend")
    end

    it "returns the route with redirect" do
      result = Route.find_matching_route("/redirect-path")
      expect(result).to eq(route_redirect)
      expect(result.backend).to eq("redirect")
    end

    it "returns the route with gone status" do
      result = Route.find_matching_route("/gone-path")
      expect(result).to eq(route_gone)
      expect(result.backend).to eq("gone")
    end

    it "returns nil when no matching route is found" do
      result = Route.find_matching_route("/non-existent-path")
      expect(result).to be_nil
    end

    it "returns the exact match over prefix match" do
      result = Route.find_matching_route("/exact-over-prefix")
      expect(result).to eq(route_exact_over_prefix)
      expect(result.backend).to eq("collections")
    end

    it "returns the longer prefix match" do
      result = Route.find_matching_route("/prefix-path/longer/subpath")
      expect(result).to eq(route_longer_prefix)
      expect(result.backend).to eq("collections")
    end
  end
end

describe "#backend" do
  context "when content_item is present" do
    it "returns 'gone' if content_item is gone" do
      route = create(:route, content_item: create(:content_item, schema_name: "gone", details: nil))
      expect(route.backend).to eq("gone")
    end

    it "returns 'redirect' if content_item is a redirect" do
      route = create(:route, content_item: create(:content_item, schema_name: "redirect"))
      expect(route.backend).to eq("redirect")
    end

    it "returns the rendering_app of the content_item if not gone or redirect" do
      route = create(:route, content_item: create(:content_item, rendering_app: "collections"))
      expect(route.backend).to eq("collections")
    end
  end

  context "when publish_intent is present and content_item is not" do
    it "returns the rendering_app of the publish_intent" do
      route = create(:route, publish_intent: create(:publish_intent, rendering_app: "frontend"))
      expect(route.backend).to eq("frontend")
    end
  end

  context "when neither content_item nor publish_intent is present" do
    it "returns nil" do
      route = create(:route)
      expect(route.backend).to be_nil
    end
  end
end
