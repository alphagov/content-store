require "rails_helper"

describe FindByPath do
  let(:model_class) do
    Class.new(ContentItem) do
      def self.create(base_path: "/base-path", exact_routes: [], prefix_routes: [], redirects: [])
        routes =
          if redirects.any?
            []
          else
            [{ path: base_path, type: "exact" }] +
              Array(exact_routes).map { |path| { path:, type: "exact" } } +
              Array(prefix_routes).map { |path| { path:, type: "prefix" } }
          end
        super(base_path:, routes:, redirects:)
      end
    end
  end

  describe ".find" do
    subject { described_class.new(model_class).find(path) }
    let(:path) { "/path" }

    context "when there isn't an item matching the path" do
      it { is_expected.to be_nil }
    end

    context "when there is a base_path that matches the path" do
      let(:path) { "/base-path" }
      let!(:instance) { model_class.create }

      it { is_expected.to eq instance }
    end

    context "when there is a route exact match for the path" do
      let(:exact_route_path) { "/base-path/exact-route" }
      let(:path) { exact_route_path }
      let!(:instance) { model_class.create(exact_routes: exact_route_path) }

      it { is_expected.to eq instance }

      context "and there is also a base_path that matches the exact route path" do
        let!(:superseding_instance) { model_class.create(base_path: exact_route_path) }

        it { is_expected.to eq superseding_instance }
      end
    end

    context "when there is a redirect exact match for the path" do
      let(:exact_route_path) { "/base-path/exact-route" }
      let(:path) { exact_route_path }
      let!(:instance) do
        model_class.create(
          redirects: [
            { path: exact_route_path, type: "exact", destination: "/somewhere" },
          ],
        )
      end

      it { is_expected.to eq instance }
    end

    context "when there is a route with a prefix match" do
      let(:prefix_route_path) { "/base-path/prefix-route" }

      let!(:instance) { model_class.create(prefix_routes: prefix_route_path) }

      context "and the path matches the prefix path" do
        let(:path) { prefix_route_path }
        it { is_expected.to eq instance }
      end

      context "and the path is in a segment after the prefix path" do
        let(:path) { "/base-path/prefix-route/a/b/c" }
        it { is_expected.to eq instance }
      end

      context "and the path is a prefix at the same segment" do
        let(:path) { "/base-path/prefix-route-longer-path" }
        it "finds nothing as this isn't supported" do
          is_expected.to be nil
        end
      end

      context "but there is another item with a better path match" do
        let(:path) { "/base-path/prefix-route/with-extra/segments" }
        let!(:better_prefix_match) do
          model_class.create(
            base_path: "/base_path/prefix-route",
            prefix_routes: "/base-path/prefix-route/with-extra",
          )
        end

        it { is_expected.to eq better_prefix_match }
      end

      context "but there is another item with an exact path match" do
        let(:path) { prefix_route_path }
        let(:matching_base_path) { "/base-path/prefix-route" }
        let!(:exact_match) do
          model_class.create(
            base_path: matching_base_path,
            exact_routes: prefix_route_path,
          )
        end

        it { is_expected.to eq exact_match }
      end
    end
  end
end
