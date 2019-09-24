require "rails_helper"

describe FindByPath do
  # Using an actual Model as it's a real pain to mock mongoid criterias and
  # similar
  class CompatibleModel
    include Mongoid::Document
    field :base_path, type: String
    field :routes, type: Array, default: []
    field :redirects, type: Array, default: []
  end

  FactoryBot.define do
    factory :compatible_model do
      base_path { "/base-path" }
      transient do
        exact_routes { [] }
        prefix_routes { [] }
      end
      routes do
        [{ path: base_path, type: "exact" }] +
          Array(exact_routes).map { |path| { path: path, type: "exact" } } +
          Array(prefix_routes).map { |path| { path: path, type: "prefix" } }
      end
    end
  end

  let(:model_class) { CompatibleModel }

  describe ".find" do
    subject { described_class.new(model_class).find(path) }
    let(:path) { "/path" }

    context "when there isn't an item matching the path" do
      it { is_expected.to be_nil }
    end

    context "when there is a base_path that matches the path" do
      let(:path) { "/base-path" }
      let!(:instance) { create(:compatible_model, base_path: "/base-path") }

      it { is_expected.to eq instance }
    end

    context "when there is a route exact match for the path" do
      let(:exact_route_path) { "/base-path/exact-route" }
      let(:path) { exact_route_path }
      let!(:instance) { create(:compatible_model, exact_routes: exact_route_path) }

      it { is_expected.to eq instance }

      context "and there is also a base_path that matches the exact route path" do
        let!(:superseding_instance) { create(:compatible_model, base_path: exact_route_path) }

        it { is_expected.to eq superseding_instance }
      end
    end

    context "when there is a redirect exact match for the path" do
      let(:exact_route_path) { "/base-path/exact-route" }
      let(:path) { exact_route_path }
      let!(:instance) do
        create(
          :compatible_model,
          routes: [],
          redirects: [
            { path: exact_route_path, type: "exact", destination: "/somewhere" },
          ],
        )
      end

      it { is_expected.to eq instance }
    end

    context "when there is a route with a prefix match" do
      let(:prefix_route_path) { "/base-path/prefix-route" }

      let!(:instance) { create(:compatible_model, prefix_routes: prefix_route_path) }

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
          create(
            :compatible_model,
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
          create(
            :compatible_model,
            base_path: matching_base_path,
            exact_routes: prefix_route_path,
          )
        end

        it { is_expected.to eq exact_match }
      end
    end
  end
end
