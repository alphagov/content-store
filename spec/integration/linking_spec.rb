require 'rails_helper'

describe "links between items", :type => :request do
  before :each do
    # Create items we can link to
    @linked_a = create(:content_item, :with_content_id)
    @linked_b = create(:content_item, :with_content_id)

    @data = {
      "base_path" => "/vat-rates",
      "content_id" => SecureRandom.uuid,
      "title" => "VAT rates",
      "format" => "answer",
      "update_type" => "major",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "routes" => [
        { "path" => "/vat-rates", "type" => 'exact' }
      ],
    }
  end

  it "looks up links to published items" do
    pending "link lookups"

    # Create two published items and one unpublished item
    linked_ids = [@linked_a, @linked_b].map(&:content_id) + [SecureRandom.uuid]
    data_with_links = @data.merge({
      "links" => { "related" => linked_ids }
    })
    put_json "/content/vat-rates", data_with_links
    expect(response.status).to eq(201)

    get "/content/vat-rates"
    site_item = JSON.parse(response.body)
    expect(site_item).to include("links")
    expect(site_item["links"].keys).to eq(["related"])

    base_paths = site_item["links"]["related"].map { |item| item["base_path"] }
    expect(base_paths).to eq(
      [@linked_a, @linked_b].map(&:base_path)
    )
  end
end
