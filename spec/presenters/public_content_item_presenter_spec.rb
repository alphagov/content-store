require 'rails_helper'

describe PublicContentItemPresenter do
  let(:item) { build(:content_item) }
  let(:presenter) { PublicContentItemPresenter.new(item) }

  it "only includes public attributes" do
    expect(presenter.as_json.keys).to match_array(PublicContentItemPresenter::PUBLIC_ATTRIBUTES)
  end

  it "outputs the base_path correctly" do
    expect(presenter.as_json["base_path"]).to eq(item.base_path)
  end
end
