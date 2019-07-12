require 'rails_helper'

describe "Public API requests for content items", type: :request do
  let(:content_item) do
    FactoryBot.create(
      :content_item,
      document_type: "travel_advice",
      expanded_links: { 'related' => [{ content_id: linked_item.content_id }] },
      description: [
        { content_type: "text/html", content: "<p>content</p>" },
        { content_type: "text/plain", content: "content" },
      ],
      details: {
        body: [
          { content_type: "text/html", content: "<p>content</p>" },
          { content_type: "text/plain", content: "content" },
        ]
      }
    )
  end

  let(:linked_item) { FactoryBot.create(:content_item, :with_content_id) }

  it "corrrectly expands linked items with Public API URLs" do
    get "/api/content#{content_item.base_path}"
    data = JSON.parse(response.body)
    expect(data["links"]["related"].first["content_id"]).to eq(linked_item.content_id)
  end

  it "inlines the 'text/html' content type" do
    get "/api/content#{content_item.base_path}"
    data = JSON.parse(response.body)

    expect(data["description"]).to eq("<p>content</p>")
    expect(data["details"]["body"]).to eq("<p>content</p>")
  end

  context "when we match on a path in routes and not a base path" do
    before do
      create(
        :content_item,
        base_path: "/base-path",
        routes: [
          { path: "/base-path", type: "exact" },
          { path: "/base-path/segment", type: "exact" },
        ]
      )
    end

    it "redirects to public API" do
      get "/api/content/base-path/segment"
      expect(response).to redirect_to("/api/content/base-path")
    end
  end
end
