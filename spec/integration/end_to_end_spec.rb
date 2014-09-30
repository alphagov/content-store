require 'rails_helper'

describe "End-to-end behaviour", :type => :request do

  let(:data) {{
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
  }}

  def create_item(data_hash)
    put_json "/content#{data_hash["base_path"]}", data_hash
    expect(response.status).to eq(201)
  end

  it "should allow items to be added and retrieved" do
    create_item(data)

    get "/content/vat-rates"
    expect(response.status).to eq(200)
    expect(response.content_type).to eq("application/json")
    response_data = JSON.parse(response.body)

    expect(response_data["title"]).to eq("VAT rates")
    # More detailed checks in fetching_content_item_spec
  end

  describe "linking items" do
    let(:linked_data_1) { attributes_for(:content_item, :with_content_id).stringify_keys }
    let(:linked_data_2) { attributes_for(:content_item, :with_content_id).stringify_keys }
    let(:linked_data_3) { attributes_for(:content_item, :with_content_id).stringify_keys }
    let(:data_with_links) do
      data.merge({
        "links" => {
          "related" => [linked_data_1["content_id"], linked_data_3["content_id"]],
          "connected" => [linked_data_2["content_id"], linked_data_1["content_id"]],
        },
      })
    end

    it "should return details of linked items, ignoring missing ones" do
      create_item(linked_data_1)
      create_item(linked_data_2)

      create_item(data_with_links)

      get "/content/vat-rates"
      expect(response.status).to eq(200)
      links = JSON.parse(response.body)["links"]

      expect(links.keys).to match_array(["connected", "related"])

      related_paths = links["related"].map {|i| i["base_path"] }
      expect(related_paths).to eq([linked_data_1["base_path"]]) # ignored linked_3 entry

      connected_paths = links["connected"].map {|i| i["base_path"] }
      expect(connected_paths).to eq([linked_data_2["base_path"], linked_data_1["base_path"]])
    end

    it "should include details of items that were added after the original item" do
      create_item(linked_data_1)

      create_item(data_with_links)

      create_item(linked_data_3)

      get "/content/vat-rates"
      expect(response.status).to eq(200)
      links = JSON.parse(response.body)["links"]

      expect(links.keys).to match_array(["connected", "related"])

      related_paths = links["related"].map {|i| i["base_path"] }
      expect(related_paths).to eq([linked_data_1["base_path"], linked_data_3["base_path"]])

      connected_paths = links["connected"].map {|i| i["base_path"] }
      expect(connected_paths).to eq([linked_data_1["base_path"]])
    end
  end
end
