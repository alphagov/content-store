require 'rails_helper'

describe ContentItem::BasePathForPath do
  describe ".call" do
    subject { described_class.(path) }
    let(:path) { "/path" }

    context "when there isn't a content item matching the path" do
      before { create(:content_item, base_path: "/test") }
      it { is_expected.to be_nil }
    end

    context "when there is a base_path that matches the path" do
      let(:base_path) { "/base-path" }
      let(:path) { base_path }

      before { create(:content_item, base_path: base_path) }

      it { is_expected.to eq base_path }
    end

    context "when there is a route exact match for the path" do
      let(:base_path) { "/base-path" }
      let(:exact_route_path) { "/base-path/exact-route" }
      let(:path) { exact_route_path }

      before do
        create(:content_item,
          base_path: base_path,
          routes: [
            { path: exact_route_path, type: "exact" },
          ],
        )
      end

      it { is_expected.to eq base_path }

      context "and there is also a base_path that matches the exact route path" do
        let(:superseding_base_path) { exact_route_path }

        before { create(:content_item, base_path: superseding_base_path) }

        it { is_expected.to eq superseding_base_path }
      end
    end

    context "when there is a route with a prefix match" do
      let(:base_path) { "/base-path" }
      let(:prefix_route_path) { "/base-path/prefix-route" }

      before do
        create(:content_item,
          base_path: base_path,
          routes: [{ path: prefix_route_path, type: "prefix" }],
        )
      end

      context "and the path matches the prefix path" do
        let(:path) { prefix_route_path }
        it { is_expected.to eq base_path }
      end

      context "and the path is in a segment after the prefix path" do
        let(:path) { "/base-path/prefix-route/a/b/c" }
        it { is_expected.to eq base_path }
      end

      context "and the path is a prefix at the same segment" do
        let(:path) { "/base-path/prefix-route-longer-path" }
        it "finds nothing as this isn't supported" do
          is_expected.to be nil
        end
      end

      context "but there is another item with a better path match" do
        let(:path) { "/base-path/prefix-route/with-extra/segments" }
        let(:matching_base_path) { "/base-path/prefix-route" }
        before do
          create(:content_item,
            base_path: matching_base_path,
            routes: [
              { path: "/base-path/prefix-route/with-extra", type: "prefix" },
            ],
          )
        end

        it { is_expected.to eq matching_base_path }
      end

      context "but there is another item with an exact path match" do
        let(:path) { prefix_route_path }
        let(:matching_base_path) { "/base-path/prefix-route" }
        before do
          create(:content_item,
            base_path: matching_base_path,
            routes: [{ path: prefix_route_path, type: "exact" }],
          )
        end

        it { is_expected.to eq matching_base_path }
      end
    end
  end
end
