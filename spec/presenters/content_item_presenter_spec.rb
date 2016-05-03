require 'rails_helper'

describe ContentItemPresenter do
  let(:expanded_links) do
    {
      "parent" => [
        {
          "base_path" => "/foo",
          "title" => "foo",
        },
        {
          "base_path" => "/bar",
          "title" => "bar",
        }
      ]
    }
  end
  let(:item) { build(:content_item, links: links, locale: locale, expanded_links: expanded_links) }
  let(:links) { {} }
  let(:locale) { "en" }

  let(:api_url_method) do
    lambda { |base_path| "http://api.example.com/content/#{base_path}" }
  end
  let(:presenter) { ContentItemPresenter.new(item, api_url_method) }

  it "includes public attributes" do
    expected_fields = ContentItemPresenter::PUBLIC_ATTRIBUTES + %w(links description details)
    expect(presenter.as_json.keys).to match_array(expected_fields)
  end

  it "outputs the base_path correctly" do
    expect(presenter.as_json["base_path"]).to eq(item.base_path)
  end

  it "presents expanded_links" do
    expect(presenter.as_json["expanded_links"]).to eq(expanded_links)
  end

  context "with related links" do
    let(:linked_item1) { create(:content_item, :with_content_id) }
    let(:linked_item2) { create(:content_item, :with_content_id) }
    let(:links) { { "related" => [linked_item1.content_id, linked_item2.content_id] } }

    it "includes the link type" do
      expect(presenter.as_json).to have_key("links")
      expect(presenter.as_json["links"].keys).to include("related")
    end

    it "includes each linked item" do
      expect(presenter.as_json["links"]["related"].size).to be(2)
    end
  end

  describe "content type resolution" do
    let(:item) do
      FactoryGirl.create(
        :content_item,
        links: links,
        description: [
          { content_type: "text/html", content: "<p>content</p>" },
          { content_type: "text/plain", content: "content" },
        ],
        details: {
          body: [
            { content_type: "text/html", content: "<p>content</p>" },
            { content_type: "text/plain", content: "content" },
          ],
        }
      )
    end

    it "inlines the 'text/html' content type in the description" do
      expect(presenter.as_json["description"]).to eq("<p>content</p>")
    end

    it "inlines the 'text/html' content type in the details" do
      expect(presenter.as_json["details"]).to eq(body: "<p>content</p>")
    end
  end
end
