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
  let(:item) { build(:content_item, schema_name: "travel_advice", locale:, expanded_links:) }
  let(:locale) { "en" }

  let(:presenter) { ContentItemPresenter.new(item) }

  it "includes public attributes" do
    expected_fields = ContentItemPresenter::PUBLIC_ATTRIBUTES + %w[links description details]
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
      expect(presenter.as_json["details"]).to eq({ body: "<p>content</p>" }.as_json)
    end

    it "inlines the 'text/html' content type in the links" do
      expect(presenter.as_json["links"]["person"].first["details"]).to eq({ body: "<p>content</p>" }.as_json)
    end
  end

  it "validates against the schema" do
    content_item = create(:content_item, :with_content_id, schema_name: "generic", document_type: "answer")

    presented = ContentItemPresenter.new(content_item).as_json

    expect(presented.to_json).to be_valid_against_frontend_schema("generic")
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
        document_type: "answer",
        publishing_scheduled_at: Time.zone.local(2018, 6, 1, 9, 30),
        scheduled_publishing_delay_seconds: 130,
      )

      presented = ContentItemPresenter.new(content_item).as_json

      expect(presented.to_json).to be_valid_against_frontend_schema("generic")
    end
  end

  it "renders timestamps in iso8601 format" do
    content_item = create(:content_item, first_published_at: Time.zone.now, publishing_scheduled_at: Time.zone.now)
    presented = ContentItemPresenter.new(content_item).as_json
    %w[updated_at public_updated_at first_published_at publishing_scheduled_at].each do |key|
      expect(presented[key]).to eq(content_item[key].iso8601)
    end
  end

  context "when some timestamps are nil" do
    it "renders them as nil" do
      content_item = build(:content_item, public_updated_at: nil, first_published_at: nil, publishing_scheduled_at: nil)
      presented = ContentItemPresenter.new(content_item).as_json
      %w[public_updated_at first_published_at publishing_scheduled_at].each do |key|
        expect(presented[key]).to be_nil
      end
    end
  end

  describe "sorting the hash" do
    let(:item) do
      FactoryBot.create(
        :content_item,
        expanded_links:
          {
            group_2: [
              { base_path: "/group-1/link-1", api_path: "/api/content/group-1/link-1" },
              { base_path: "/group-1/link-2", api_path: "/api/content/group-1/link-2" },
              { base_path: "/group-1/link-3", api_path: "/api/content/group-1/link-3" },
            ],
            group_1: [
              { base_path: "/group-2/link-3", api_path: "/api/content/group-2/link-3" },
              { base_path: "/group-2/link-2", api_path: "/api/content/group-2/link-2" },
              { base_path: "/group-2/link-1", api_path: "/api/content/group-2/link-1" },
            ],
          },
      )
    end
    let(:result) { ContentItemPresenter.new(item).as_json }
    let(:result_links) { result["links"] }

    it "returns the keys in alphabetical order" do
      expect(result.keys).to eq(result.keys.sort)
    end

    it "returns the link groups in alphabetical order of their keys" do
      expect(result_links.keys).to eq(result_links.keys.sort)
    end

    it "returns the keys within each link in alphabetical order" do
      result_links.each_key do |group|
        expect(result_links[group].all? { |link| link.keys == link.keys.sort }).to eq(true)
      end
    end

    it "does not sort the arrays within the link groups" do
      expect(result_links["group_1"].map { |e| e[:base_path] }).to eq(item.expanded_links["group_1"].map { |e| e[:base_path] })
    end
  end
end
