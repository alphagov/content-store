require 'rails_helper'

describe PublicContentItemPresenter do
  let(:item) { build(:content_item) }
  let(:presenter) { PublicContentItemPresenter.new(item) }

  it "includes public attributes" do
    expected_fields = PublicContentItemPresenter::PUBLIC_ATTRIBUTES + ["links"]
    expect(presenter.as_json.keys).to match_array(expected_fields)
  end

  it "outputs the base_path correctly" do
    expect(presenter.as_json["base_path"]).to eq(item.base_path)
  end

  context "with related links" do
    let(:linked_items) { create_list(:content_item, 2, :with_content_id) }
    let(:item) { build(:content_item, :links => {"related" => linked_items.map(&:content_id)}) }

    it "includes the link type" do
      expect(presenter.as_json).to have_key("links")
      expect(presenter.as_json["links"].keys).to eq(["related"])
    end

    it "includes each linked item" do
      expect(presenter.as_json["links"]["related"].size).to be(2)
    end

    it "includes the path and title for each item" do
      related = presenter.as_json["links"]["related"]
      expect(related).to all include("base_path", "title")
    end
  end
end
