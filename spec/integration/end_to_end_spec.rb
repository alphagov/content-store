require 'rails_helper'

describe "End-to-end behaviour", :type => :request do

  let(:data) {{
    "locale" => "en",
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
    let(:linked_data_1) { attributes_for(:content_item, :with_content_id, locale: "en").stringify_keys }
    let(:linked_data_2) { attributes_for(:content_item, :with_content_id, locale: "en").stringify_keys }

    subject(:links) {
      get "/content/vat-rates"
      expect(response.status).to eq(200)
      links = JSON.parse(response.body)["links"]
    }

    context "linked item which already existed" do
      before(:each) {
        create_item(linked_data_1)
        create_item(data.merge(
          "links" => {
            "related" => [linked_data_1["content_id"]],
            "connected" => []
          }
        ))
      }

      it "should include all like hash keys even if empty" do
        expect(links.keys).to match_array(["connected", "related"])
      end

      it "should return details of linked items" do
        related_paths = links["related"].map {|i| i["base_path"] }
        expect(related_paths).to eq([linked_data_1["base_path"]])
      end

      it "should include the locale of the linked item" do
        expect(links["related"].map { |i| i["locale"] }).to eq([linked_data_1["locale"]])
      end
    end

    context "linked item which does not exist" do
      before(:each) {
        create_item(linked_data_1)
        create_item(data.merge(
          "links" => {
            "related" => [linked_data_1["content_id"], linked_data_2["content_id"]]
          }
        ))
      }

      it "should ignore the missing one" do
        related_paths = links["related"].map {|i| i["base_path"] }
        expect(related_paths).not_to include(linked_data_2["base_path"])
        expect(related_paths).to include(linked_data_1["base_path"])
      end
    end

    context "linked item added after the original item" do
      before(:each) {
        create_item(data.merge(
          "links" => {
            "related" => [linked_data_1["content_id"]]
          }
        ))
        create_item(linked_data_1)
      }

      it "should include details of items" do
        related_paths = links["related"].map {|i| i["base_path"] }
        expect(related_paths).to eq([linked_data_1["base_path"]])
      end
    end

    context "translations of linked items exist" do
      let(:linked_data_1_fr) {
        attributes_for(:content_item,
          content_id: linked_data_1["content_id"],
          locale: "fr",
          base_path: linked_data_1["base_path"] + ".fr"
        ).stringify_keys
      }

      before(:each) {
        create_item(linked_data_1_fr)
        create_item(linked_data_1)
        create_item(linked_data_2)
        create_item(data.merge(
          "locale" => "fr",
          "links" => {
            "related" => [linked_data_1["content_id"], linked_data_2["content_id"]]
          }
        ))
      }

      it "should link by preference to the item with matching locale" do
        expect(links["related"][0]["base_path"]).to eq(linked_data_1_fr["base_path"])
        expect(links["related"][0]["locale"]).to eq(linked_data_1_fr["locale"])
      end

      it "should fall back on the english version if no item found with matching locale" do
        expect(links["related"][1]["base_path"]).to eq(linked_data_2["base_path"])
        expect(links["related"][1]["locale"]).to eq(linked_data_2["locale"])
      end
    end
  end
end
