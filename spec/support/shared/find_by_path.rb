shared_examples "find_by_path" do |factory|
  context "when no paths match" do
    let(:path) { "/non-existant" }
    it { is_expected.to be nil }
  end

  context "when base_path matches" do
    let(:path) { "/base-path" }
    let!(:match) { create(factory, base_path: path) }
    it { is_expected.to eq match }
  end

  context "when an exact route matches" do
    let(:path) { "/base-path/exact-route" }
    let!(:match) do
      create(
        factory,
        base_path: "/base-path",
        routes: [
          { path: "/base-path", type: "exact" },
          { path: path, type: "exact" },
        ],
      )
    end
    it { is_expected.to eq match }
  end

  context "when a prefix route matches" do
    let(:path) { "/base-path/prefix-route/that-is/very-deep" }
    let!(:match) do
      create(
        factory,
        base_path: "/base-path",
        routes: [
          { path: "/base-path", type: "exact" },
          { path: "/base-path/prefix-route", type: "prefix" },
        ],
      )
    end
    it { is_expected.to eq match }
  end
end
