require 'rails_helper'

describe ContentItemPresenter do
  let(:item) { build(:content_item) }
  let(:api_url_method) do
    lambda { |base_path| "http://api.example.com/content/#{base_path}" }
  end
  let(:presenter) { ContentItemPresenter.new(item, api_url_method) }

  it "includes public attributes" do
    expected_fields = ContentItemPresenter::PUBLIC_ATTRIBUTES + ["links"]
    expect(presenter.as_json.keys).to match_array(expected_fields)
  end

  it "outputs the base_path correctly" do
    expect(presenter.as_json["base_path"]).to eq(item.base_path)
  end

  context "with related links" do
    let(:linked_item1) { create(:content_item, :with_content_id, locale: I18n.default_locale.to_s) }
    let(:linked_item2) { create(:content_item, :with_content_id, locale: "fr") }
    let(:item) {
      build(:content_item,
        :links => {"related" => [linked_item1.content_id, linked_item2.content_id]},
        :locale => 'fr'
      )
    }

    let(:related) { presenter.as_json["links"]["related"] }

    it "includes the link type" do
      expect(presenter.as_json).to have_key("links")
      expect(presenter.as_json["links"].keys).to match_array(["available_translations", "related"])
    end

    it "includes each linked item" do
      expect(related.size).to be(2)
    end

    it "includes the path, title and description for each item" do
      expect(related).to all include("base_path", "title", "description")
    end

    it "includes the locale for each item" do
      expect(related.map { |item| item['locale'] }).to eq(['en', 'fr'])
    end

    it "links to the API URL for each item" do
      expect(related.map { |item| item["api_url"] }).to eq(
        [
          "http://api.example.com/content#{linked_item1.base_path}",
          "http://api.example.com/content#{linked_item2.base_path}",
        ]
      )
    end

    it "links to the web URL for each item" do
      site_root = Plek.current.website_root
      expect(related.map { |item| item["web_url"] }).to eq(
        [
          "#{site_root}#{linked_item1.base_path}",
          "#{site_root}#{linked_item2.base_path}",
        ]
      )
    end
  end
end
