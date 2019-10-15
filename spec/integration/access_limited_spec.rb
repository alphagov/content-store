require "rails_helper"

describe "Fetching an access-limited by content item", type: :request do
  context "access limited by user id" do
    let(:access_limited_content_item) { create(:access_limited_content_item, :by_user_id) }
    let(:authorised_user_uid) { access_limited_content_item.access_limited["users"].first }
    context "request without an authentication header" do
      it "returns a 403 (Forbidden) response" do
        get "/content/#{access_limited_content_item.base_path}"

        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request with an authorised user ID specified in the header" do
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "X-Govuk-Authenticated-User" => authorised_user_uid }
      end

      it "returns the details for the requested item" do
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")

        data = JSON.parse(response.body)
        expect(data["title"]).to eq(access_limited_content_item.title)
      end

      it "marks the cache-control as private" do
        expect(cache_control["private"]).to eq(true)
      end
    end

    context "request with an unauthorised user ID specified in the header" do
      it "returns a 403 (Forbidden) response" do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "X-Govuk-Authenticated-User" => "unauthorised-user" }

        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request with an invalid user ID specified in the header" do
      it "returns a 403 (Forbidden) response" do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "X-Govuk-Authenticated-User" => "invalid" }

        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request has valid user ID but invalid bypass ID" do
      let(:access_limited_content_item) { create(:access_limited_content_item, :by_user_id, :with_auth_bypass_id) }
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: {
              "X-Govuk-Authenticated-User" => authorised_user_uid,
              "Govuk-Auth-Bypass-Id" => "fake id",
             }
      end

      it "returns a 403 (Forbidden) response" do
        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request has an invalid user ID and invalid bypass ID" do
      let(:access_limited_content_item) { create(:access_limited_content_item, :by_user_id, :with_auth_bypass_id) }
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: {
              "X-Govuk-Authenticated-User" => "fake user id",
              "Govuk-Auth-Bypass-Id" => "fake bypass id",
             }
      end

      it "returns a 403 response" do
        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end
  end

  context "access limited by org id" do
    let(:access_limited_content_item) { create(:access_limited_content_item, :by_org_id) }
    let(:auth_org_id) { access_limited_content_item.access_limited["organisations"].first }
    context "request without an authentication header" do
      it "returns a 403 (Forbidden) response" do
        get "/content/#{access_limited_content_item.base_path}"

        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request with an authorised org ID specified in the header" do
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "X-Govuk-Authenticated-User-Organisation" => auth_org_id }
      end

      it "returns the details for the requested item" do
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")

        data = JSON.parse(response.body)
        expect(data["title"]).to eq(access_limited_content_item.title)
      end

      it "marks the cache-control as private" do
        expect(cache_control["private"]).to eq(true)
      end
    end

    context "request with an unauthorised org ID specified in the header" do
      it "returns a 403 (Forbidden) response" do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "X-Govuk-Authenticated-User-Organisation" => "unauthorised-org" }

        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request with an invalid org ID specified in the header" do
      it "returns a 403 (Forbidden) response" do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "X-Govuk-Authenticated-User-Organisation" => "invalid" }

        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request has valid org ID but invalid bypass ID" do
      let(:access_limited_content_item) { create(:access_limited_content_item, :by_org_id, :with_auth_bypass_id) }
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: {
              "X-Govuk-Authenticated-User-Organisation" => auth_org_id,
              "Govuk-Auth-Bypass-Id" => "fake id",
             }
      end

      it "returns a 403 (Forbidden) response" do
        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end
  end

  context "access limited by bypass id" do
    let(:access_limited_content_item) { create(:access_limited_content_item, :with_auth_bypass_id) }
    let(:auth_bypass_id) { access_limited_content_item.auth_bypass_ids.first }



    context "request with an authorised bypass ID specified in the header" do
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "Govuk-Auth-Bypass-Id" => auth_bypass_id }
      end

      it "returns the details for the requested item" do
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")

        data = JSON.parse(response.body)
        expect(data["title"]).to eq(access_limited_content_item.title)
      end

      it "marks the cache-control as private" do
        expect(cache_control["private"]).to eq(true)
      end
    end

    context "request without an bypass ID, but a user ID specified in the header" do
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "X-Govuk-Authenticated-User" => "some-user" }
      end

      it "returns the details for the requested item" do
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")

        data = JSON.parse(response.body)
        expect(data["title"]).to eq(access_limited_content_item.title)
      end
    end

    context "request with an unauthorised bypass ID specified in the header" do
      it "returns a 403 (Forbidden) response" do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: { "Govuk-Auth-Bypass-Id" => SecureRandom.uuid }

        json = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(json["errors"]["type"]).to eq("access_forbidden")
        expect(json["errors"]["code"]).to eq("403")
      end
    end

    context "request with an authorised bypass ID and an 'invalid' user_id" do
      before do
        get "/content/#{access_limited_content_item.base_path}",
            params: {}, headers: {
              "X-Govuk-Authenticated-User" => "invalid",
              "Govuk-Auth-Bypass-Id" => auth_bypass_id,
            }
      end

      it "returns the details for the requested item" do
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")

        data = JSON.parse(response.body)
        expect(data["title"]).to eq(access_limited_content_item.title)
      end
    end
  end
end
