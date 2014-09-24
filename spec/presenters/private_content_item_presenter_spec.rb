require 'rails_helper'

describe PrivateContentItemPresenter do
  let(:item) { build(:content_item) }
  let(:presenter) { PrivateContentItemPresenter.new(item) }

  it "outputs the base_path correctly" do
    expect(presenter.as_json["base_path"]).to eq(item.base_path)
  end

  it "does not output the _id field" do
    expect(presenter.as_json).not_to have_key("_id")
  end

  it "does not include the 'errors' key if there are no errors" do
    expect(presenter.as_json).not_to have_key("errors")
  end

  it "includes private fields" do
    expect(presenter.as_json.keys).to include("publishing_app", "rendering_app", "routes")
  end

  it "includes an update type" do
    expect(presenter.as_json["update_type"]).to eq("minor")
  end

  context "with validation errors" do
    let(:item) { build(:content_item, :with_blank_title).tap(&:valid?) }

    it "includes details of any errors" do
      json_hash = presenter.as_json
      expect(json_hash).to have_key("errors")
      expect(json_hash["errors"]).to eq({"title" => ["can't be blank"]})
    end
  end
end
