require 'rails_helper'

describe "End-to-end behaviour", :type => :request do

  let(:data) {{
    "locale" => "en",
    "base_path" => "/vat-rates",
    "content_id" => SecureRandom.uuid,
    "title" => "VAT rates",
    "format" => "answer",
    "publishing_app" => "publisher",
    "rendering_app" => "frontend",
    "routes" => [
      { "path" => "/vat-rates", "type" => 'exact' }
    ],
    "public_updated_at" => Time.now
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

      it "should include all link hash keys even if empty" do
        expect(links.keys).to include("connected")
        expect(links.keys).to include("related")
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

  describe "available_translations" do
    before(:each) { create_item(data) }

    subject(:links) {
      get "/content#{data['base_path']}"
      expect(response.status).to eq(200)
      links = JSON.parse(response.body)["links"]
    }

    context "an item without any translation" do
      it "should include available_translations" do
        expect(links.keys).to include("available_translations")
      end

      it "should include a link to itself in available_translations" do
        expect(links["available_translations"].first["title"]).to eq(data["title"])
        expect(links["available_translations"].first["base_path"]).to eq(data["base_path"])
        expect(links["available_translations"].first["locale"]).to eq(data["locale"])
      end
    end

    context "an item with multiple translations" do
      before(:each) do
        create_item(data.merge(
          "locale" => "fr",
          "base_path" => "/vat-rates.fr",
          "title" => "Taux de TVA",
          "routes" => [
            { "path" => "/vat-rates.fr", "type" => 'exact' }
          ]
        ))
        create_item(data.merge(
          "locale" => "de",
          "base_path" => "/vat-rates.de",
          "title" => "Mehrwertsteuersätze",
          "routes" => [
            { "path" => "/vat-rates.de", "type" => 'exact' }
          ]
        ))
      end

      it "should include a links to each available locale in alphabetical order" do
        expect(links["available_translations"].map {|t| t["locale"]}).to eq(%w{de en fr})
      end

      it "should include titles of each available_translation" do
        expect(links["available_translations"].map {|t| t["title"]}).to eq(['Mehrwertsteuersätze', 'VAT rates', 'Taux de TVA'])
      end

      it "should include base_path of each available_tranlsation" do
        expect(links["available_translations"].map {|t| t["base_path"]}).to eq(['/vat-rates.de', '/vat-rates', '/vat-rates.fr'])
      end
    end
  end
end
