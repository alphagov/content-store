require 'rails_helper'

describe ContentItemPresenter do
  let(:item) { build(:content_item, links: links, locale: locale) }
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

  context "with related links" do
    let(:linked_item1) { create(:content_item, :with_content_id, locale: I18n.default_locale.to_s) }
    let(:linked_item2) { create(:content_item, :with_content_id, locale: "fr", analytics_identifier: "D2") }
    let(:links) { { "related" => [linked_item1.content_id, linked_item2.content_id] } }
    let(:locale) { "fr" }
    let(:related) { presenter.as_json["links"]["related"] }

    it "includes the link type" do
      expect(presenter.as_json).to have_key("links")
      expect(presenter.as_json["links"].keys).to include("related")
    end

    it "includes each linked item" do
      expect(related.size).to be(2)
    end

    it "includes the content_id, path, title and description for each item" do
      expect(related).to all include("content_id", "base_path", "title", "description")
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

    it "contains the linked analytics identifier" do
      expect(related[1]).to have_key("analytics_identifier")
      expect(related[1]["analytics_identifier"]).to eq('D2')
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

    context "with related links" do
      let(:linked_item) do
        FactoryGirl.create(
          :content_item,
          :with_content_id,
          locale: I18n.default_locale.to_s,
          description: [
            { content_type: "text/html", content: "<p>linked content</p>" },
            { content_type: "text/plain", content: "linked content" },
          ],
        )
      end

      let(:links) { { "related" => [linked_item.content_id] } }

      it "inlines the 'text/html' content type in the linked description" do
        related = presenter.as_json["links"]["related"]
        expect(related.first["description"]).to eq("<p>linked content</p>")
      end
    end
  end
end
