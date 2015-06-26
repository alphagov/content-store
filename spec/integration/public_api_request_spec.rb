require 'rails_helper'

describe "Public API requests for content items", :type => :request do
  let(:content_item) { create(:content_item, links: { 'related' => [linked_item.content_id] }) }
  let(:linked_item) { create(:content_item, :with_content_id) }

  it "corrrectly expands linked items with API URLs" do
    get_api_content content_item

    data = JSON.parse(response.body)

    expect(data["links"]["related"].first["api_url"]).to eq("http://www.example.com/api/content#{linked_item.base_path}")
  end
end
