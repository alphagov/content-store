require "rails_helper"

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
        },
      ],
    }
  end
  let(:item) { build(:content_item, document_type: "travel_advice", locale: locale, expanded_links: expanded_links) }
  let(:locale) { "en" }

  let(:presenter) { ContentItemPresenter.new(item) }

  it "includes public attributes" do
    expected_fields = ContentItemPresenter::PUBLIC_ATTRIBUTES + %w(links description details updated_at)
    expect(presenter.as_json.keys).to match_array(expected_fields)
  end

  it "outputs the base_path correctly" do
    expect(presenter.as_json["base_path"]).to eq(item.base_path)
  end

  describe "content type resolution" do
    let(:item) do
      FactoryBot.create(
        :content_item,
        expanded_links: {
          person: [
            {
              details: {
                body: [
                  { content_type: "text/html", content: "<p>content</p>" },
                  { content_type: "text/plain", content: "content" },
                ],
              },
            },
          ],
        },
        description: [
          { content_type: "text/html", content: "<p>content</p>" },
          { content_type: "text/plain", content: "content" },
        ],
        details: {
          body: [
            { content_type: "text/html", content: "<p>content</p>" },
            { content_type: "text/plain", content: "content" },
          ],
        },
      )
    end

    it "inlines the 'text/html' content type in the description" do
      expect(presenter.as_json["description"]).to eq("<p>content</p>")
    end

    it "inlines the 'text/html' content type in the details" do
      expect(presenter.as_json["details"]).to eq(body: "<p>content</p>")
    end

    it "inlines the 'text/html' content type in the links" do
      expect(presenter.as_json["links"][:person].first[:details]).to eq(body: "<p>content</p>")
    end
  end

  it "validates against the schema" do
    content_item = create(:content_item, :with_content_id, schema_name: "generic")

    presented = ContentItemPresenter.new(content_item).as_json

    expect(presented.to_json).to be_valid_against_schema("generic")
  end

  context "when schema_name is not redirect" do
    it "doesn't include redirects field" do
      content_item = create(:content_item)
      presented = ContentItemPresenter.new(content_item).as_json
      expect(presented.keys).to_not include("redirects")
    end
  end

  context "when schema_name is redirect" do
    it "includes the redirects field" do
      content_item = create(:redirect_content_item)
      presented = ContentItemPresenter.new(content_item).as_json
      expect(presented.keys).to include("redirects")
    end
  end

  context "when content has scheduled publishing details" do
    it "validates against the schema" do
      content_item = create(
        :content_item,
        :with_content_id,
        schema_name: "generic",
        publishing_scheduled_at: Time.zone.local(2018, 6, 1, 9, 30),
        scheduled_publishing_delay_seconds: 130,
      )

      presented = ContentItemPresenter.new(content_item).as_json

      expect(presented.to_json).to be_valid_against_schema("generic")
    end
  end

  context "when there is a homepage content item" do
    it "embeds the global field when data is set on the homepage" do
      global = { "header" => "header", "footer" => "footer" }
      create(:content_item_with_content_id,
             base_path: "/",
             details: { global: global })
      content_item = create(:content_item)
      presented = ContentItemPresenter.new(content_item).as_json
      expect(presented["global"]).to eq(global)
    end

    it "omits the global field when it isn't set on the homepage" do
      create(:content_item_with_content_id,
             base_path: "/",
             details: {})
      content_item = create(:content_item)
      presented = ContentItemPresenter.new(content_item).as_json
      expect(presented.keys).not_to include("global")
    end

    it "uses the homepage's updated_at when it is more recently updated" do
      create(:content_item_with_content_id,
             base_path: "/",
             updated_at: Date.today.noon)
      content_item = create(:content_item, updated_at: Date.yesterday.noon)
      presented = ContentItemPresenter.new(content_item).as_json
      expect(presented["updated_at"]).to eq(Date.today.noon)
    end

    it "uses the content_items's updated_at when it is more recently updated" do
      create(:content_item_with_content_id,
             base_path: "/",
             updated_at: 3.weeks.ago)
      content_item = create(:content_item, updated_at: Date.yesterday.noon)
      presented = ContentItemPresenter.new(content_item).as_json
      expect(presented["updated_at"]).to eq(Date.yesterday.noon)
    end
  end
end
