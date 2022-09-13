require "rails_helper"

describe "Access controls for content items", type: :request do
  let!(:content_item) do
    create(
      :content_item,
      auth_bypass_ids: [content_auth_bypass_id],
      access_limited:,
      expanded_links: {
        related: [
          {
            content_id: SecureRandom.uuid,
            auth_bypass_ids: [linked_auth_bypass_id],
          },
        ],
      },
    )
  end

  let(:content_auth_bypass_id) { SecureRandom.uuid }
  let(:linked_auth_bypass_id) { SecureRandom.uuid }

  shared_examples "returns forbidden response" do
    it "returns a forbidden response" do
      get "/content/#{content_item.base_path}", headers: headers

      json = JSON.parse(response.body)

      expect(response).to be_forbidden
      expect(json["errors"]["type"]).to eq("access_forbidden")
      expect(json["errors"]["code"]).to eq("403")
    end
  end

  shared_examples "returns private response" do
    it "returns a success response with private cache control" do
      get "/content/#{content_item.base_path}", headers: headers

      json = JSON.parse(response.body)

      expect(response).to be_ok
      expect(json["title"]).to eq(content_item.title)
      expect(cache_control["private"]).to be true
    end
  end

  shared_examples "returns public response" do
    it "returns a success response with public cache control" do
      get "/content/#{content_item.base_path}", headers: headers

      json = JSON.parse(response.body)

      expect(response).to be_ok
      expect(json["title"]).to eq(content_item.title)
      expect(cache_control["public"]).to be true
    end
  end

  describe "access limited content item by user id" do
    let(:access_limited) do
      { users: [access_limited_user_id] }
    end

    let(:access_limited_user_id) { SecureRandom.uuid }

    context "when the user is signed in and matches the user id" do
      let(:headers) do
        { "X-Govuk-Authenticated-User" => access_limited_user_id }
      end

      include_examples "returns private response"
    end

    context "when the user is signed in and doesn't match the user id" do
      let(:headers) do
        { "X-Govuk-Authenticated-User" => SecureRandom.uuid }
      end

      include_examples "returns forbidden response"

      context "and has the contents auth bypass id" do
        let(:headers) do
          {
            "X-Govuk-Authenticated-User" => SecureRandom.uuid,
            "Govuk-Auth-Bypass-Id" => content_auth_bypass_id,
          }
        end

        include_examples "returns private response"
      end

      context "and has a linked auth bypass id" do
        let(:headers) do
          {
            "X-Govuk-Authenticated-User" => SecureRandom.uuid,
            "Govuk-Auth-Bypass-Id" => linked_auth_bypass_id,
          }
        end

        include_examples "returns forbidden response"
      end
    end
  end

  describe "access limited content item by organisation id" do
    let(:access_limited) do
      { organisations: [access_limited_user_organisation_id] }
    end

    let(:access_limited_user_organisation_id) { SecureRandom.uuid }

    context "when the user is signed in and matches the organisation id" do
      let(:headers) do
        { "X-Govuk-Authenticated-User-Organisation" => access_limited_user_organisation_id }
      end

      include_examples "returns private response"
    end

    context "when the user is signed in and doesn't match the organisation id" do
      let(:headers) do
        { "X-Govuk-Authenticated-User-Organisation" => SecureRandom.uuid }
      end

      include_examples "returns forbidden response"

      context "and has the contents auth bypass id" do
        let(:headers) do
          {
            "X-Govuk-Authenticated-User-Organisation" => SecureRandom.uuid,
            "Govuk-Auth-Bypass-Id" => content_auth_bypass_id,
          }
        end

        include_examples "returns private response"
      end

      context "and has a linked auth bypass id" do
        let(:headers) do
          {
            "X-Govuk-Authenticated-User-Organisation" => SecureRandom.uuid,
            "Govuk-Auth-Bypass-Id" => linked_auth_bypass_id,
          }
        end

        include_examples "returns forbidden response"
      end
    end
  end

  describe "access limited content item by user id and organisation id" do
    let(:access_limited) do
      {
        users: [access_limited_user_id],
        organisations: [access_limited_user_organisation_id],
      }
    end

    let(:access_limited_user_id) { SecureRandom.uuid }
    let(:access_limited_user_organisation_id) { SecureRandom.uuid }

    context "when the user is signed in and matches the user id but not organisation id" do
      let(:headers) do
        {
          "X-Govuk-Authenticated-User" => access_limited_user_id,
          "X-Govuk-Authenticated-User-Organisation" => SecureRandom.uuid,
        }
      end

      include_examples "returns private response"
    end

    context "when the user is signed in and matches the organisation id but not user id" do
      let(:headers) do
        {
          "X-Govuk-Authenticated-User" => SecureRandom.uuid,
          "X-Govuk-Authenticated-User-Organisation" => access_limited_user_organisation_id,
        }
      end

      include_examples "returns private response"
    end
  end

  describe "content that is not access limited" do
    let(:access_limited) { {} }

    context "when the contents auth bypass id is included" do
      let(:headers) do
        {
          "X-Govuk-Authenticated-User-Organisation" => SecureRandom.uuid,
          "Govuk-Auth-Bypass-Id" => content_auth_bypass_id,
        }
      end

      include_examples "returns private response"
    end

    context "when the linked auth bypass id is included" do
      let(:headers) do
        {
          "X-Govuk-Authenticated-User-Organisation" => SecureRandom.uuid,
          "Govuk-Auth-Bypass-Id" => linked_auth_bypass_id,
        }
      end

      include_examples "returns private response"
    end

    context "when the user is signed in and an incorrect auth bypass id is included" do
      let(:headers) do
        {
          "X-Govuk-Authenticated-User" => SecureRandom.uuid,
          "Govuk-Auth-Bypass-Id" => SecureRandom.uuid,
        }
      end

      include_examples "returns private response"
    end

    context "when the user is not signed in and an incorrect auth bypass id is included" do
      let(:headers) do
        {
          "X-Govuk-Authenticated-User" => "invalid",
          "Govuk-Auth-Bypass-Id" => SecureRandom.uuid,
        }
      end

      include_examples "returns forbidden response"
    end

    context "when the user is not signed in and an auth bypass id is not included" do
      let(:headers) { {} }

      include_examples "returns public response"
    end
  end
end
