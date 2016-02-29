require 'rails_helper'

describe "Public API requests for content items", type: :request do
  let(:content_item) do
    FactoryGirl.create(
      :content_item,
      links: { 'related' => [linked_item.content_id] },
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

  let(:linked_item) { FactoryGirl.create(:content_item, :with_content_id) }

  it "corrrectly expands linked items with Public API URLs" do
    get_api_content content_item
    data = JSON.parse(response.body)

    expect(data["links"]["related"].first["api_url"]).to eq("http://www.example.com/api/content#{linked_item.base_path}")
  end

  it "inlines the 'text/html' content type" do
    get_api_content content_item
    data = JSON.parse(response.body)

    expect(data["description"]).to eq("<p>content</p>")
    expect(data["details"]["body"]).to eq("<p>content</p>")
  end
end
