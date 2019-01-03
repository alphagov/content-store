require 'rails_helper'

describe "End-to-end behaviour", type: :request do
  let(:data) do
    {
      "locale" => "en",
      "base_path" => "/vat-rates",
      "content_id" => SecureRandom.uuid,
      "title" => "VAT rates",
      "format" => "answer",
      "schema_name" => "answer",
      "document_type" => "travel_advice",
      "content_purpose_document_supertype" => "guidance",
      "email_document_supertype" => "publications",
      "government_document_supertype" => "new-stories",
      "navigation_document_supertype" => "guidance",
      "search_user_need_document_supertype" => "core",
      "user_journey_document_supertype" => "finding",
      "content_purpose_supergroup" => "guidance_and_regulation",
      "content_purpose_subgroup" => "guidance",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "routes" => [
        { "path" => "/vat-rates", "type" => 'exact' }
      ],
      "public_updated_at" => Time.now,
      "payload_version" => "1",
    }
  end

  def create_item(data_hash)
    put_json "/content#{data_hash['base_path']}", data_hash
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
end
