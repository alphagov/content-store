require "rails_helper"

describe "CRUD of publish intents", type: :request do
  describe "submitting a publish intent" do
    let(:publish_time) { 40.minutes.from_now }
    let(:data) do
      {
        "base_path" => "/vat-rates",
        "publish_time" => publish_time,
        "publishing_app" => "publisher",
        "rendering_app" => "frontend",
        "routes" => [
          { "path" => "/vat-rates", "type" => "exact" },
        ],
      }
    end

    context "when the user is not authenticated" do
      around do |example|
        ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
      end

      it "returns an unauthorized response" do
        put_json "/publish-intent/vat-rates", data

        expect(response).to be_unauthorized
      end
    end

    context "a new publish intent" do
      it "creates the publish intent" do
        put_json "/publish-intent/vat-rates", data

        intent = PublishIntent.where(base_path: "/vat-rates").first
        expect(intent).to be
        expect(intent.publish_time).to match_datetime(publish_time)
      end

      it "responds with a created status and an empty JSON document" do
        put_json "/publish-intent/vat-rates", data

        expect(response.status).to eq(201)
        expect(response.body).to eq("{}")
      end
    end

    context "updating an existing publish intent" do
      let!(:intent) { create(:publish_intent, base_path: "/vat-rates", publish_time: 10.minutes.from_now) }

      it "updates the publish intent" do
        put_json "/publish-intent/vat-rates", data

        intent.reload
        expect(intent.publish_time).to match_datetime(publish_time)
      end

      it "responds with an ok status" do
        put_json "/publish-intent/vat-rates", data

        expect(response.status).to eq(200)
      end
    end

    describe "registering routes for the intent" do
      context "with no corresponding content-item" do
        it "registers routes for the publish intent" do
          put_json "/publish-intent/vat-rates", data
          assert_routes_registered("frontend", [["/vat-rates", "exact"]])
        end
      end

      context "with a corresponding content-item" do
        before :each do
          create(
            :content_item,
            base_path: "/vat-rates",
            rendering_app: "frontend",
            routes: [{ "path" => "/vat-rates", "type" => "exact" }],
          )
          WebMock::RequestRegistry.instance.reset! # Clear out any requests made by factory creation.
        end

        it "does not register routes if the content item already has the routes" do
          put_json "/publish-intent/vat-rates", data
          refute_routes_registered("frontend", [["/vat-rates", "exact"]])
        end

        it "registers routes that don't already exist on the content item" do
          data["routes"] << { "path" => "/vat-rates.json", "type" => "exact" }
          put_json "/publish-intent/vat-rates", data
          assert_routes_registered("frontend", [["/vat-rates.json", "exact"]])
          assert_no_routes_registered_for_path("/vat-rates")
        end

        it "handles the intent having a different rendering app from the content item" do
          data["routes"] << { "path" => "/vat-rates.json", "type" => "exact" }
          data["rendering_app"] = "other-frontend"
          put_json "/publish-intent/vat-rates", data
          assert_routes_registered("other-frontend", [["/vat-rates.json", "exact"]])
          assert_no_routes_registered_for_path("/vat-rates")
        end
      end
    end

    it "handles non-ascii paths" do
      # URI.escape("/news/בוט לאינד")
      path = "/news/%D7%91%D7%95%D7%98%20%D7%9C%D7%90%D7%99%D7%A0%D7%93"
      put_json "/publish-intent#{path}", data.merge("base_path" => path, "routes" => [{ "path" => path, "type" => "exact" }])

      expect(response.status).to eq(201)

      expect(PublishIntent.where(base_path: path).first).to be
    end

    it "returns 422 and error details on validation error" do
      put_json "/publish-intent/vat-rates", data.merge("publish_time" => "")

      expect(response.status).to eq(422)

      data = JSON.parse(response.body)
      expect(data["errors"]).to eq("publish_time" => ["can't be blank"])

      expect(PublishIntent.where(base_path: "/vat-rates").first).not_to be
    end

    it "returns 422 and an error message with extra fields in the input" do
      put_json "/publish-intent/vat-rates", data.merge("foo" => "bar", "bar" => "baz")

      expect(response.status).to eq(422)
      data = JSON.parse(response.body)
      expect(data["errors"]).to eq("base" => ["unrecognised field(s) foo, bar in input"])
    end

    it "returns 422 and an error message with fields of the wrong type in the input" do
      put_json "/publish-intent/vat-rates", data.merge("routes" => "not an array")

      expect(response.status).to eq(422)
      data = JSON.parse(response.body)
      expected_error_message = ActiveModel::ValidationError.new(Array, String).message
      expect(data["errors"]).to eq("base" => [expected_error_message])
    end

    it "returns a 400 with bad json" do
      put "/publish-intent/foo", env: { "RAW_POST_DATA" => "I'm not json" }, headers: { "CONTENT_TYPE" => "application/json" }
      expect(response.status).to eq(400)
    end
  end

  describe "fetching details of a publish intent" do
    it "returns the intent details as json" do
      intent = create(:publish_intent, base_path: "/vat-rates", publish_time: 30.minutes.from_now)
      get "/publish-intent/vat-rates"
      expect(response.status).to eq(200)
      expect(response.media_type).to eq("application/json")

      data = JSON.parse(response.body)
      expect(data["base_path"]).to eq("/vat-rates")

      expect(data["publish_time"]).to match_datetime(intent.publish_time)
    end

    it "handles non-ascii paths" do
      # URI.escape("/news/בוט לאינד")
      path = "/news/%D7%91%D7%95%D7%98%20%D7%9C%D7%90%D7%99%D7%A0%D7%93"
      create(:publish_intent, base_path: path)
      get "/publish-intent#{path}"
      expect(response.status).to eq(200)

      data = JSON.parse(response.body)
      expect(data["base_path"]).to eq(path)
    end

    it "returns 404 for non-existent intent" do
      get "/publish-intent/non-existent"
      expect(response.status).to eq(404)
    end

    it "returns a 303 redirect for a path match" do
      create(
        :publish_intent,
        base_path: "/vat-rates",
        routes: [
          { path: "/vat-rates", type: "exact" },
          { path: "/vat-rates/exact", type: "exact" },
        ],
      )

      get "/publish-intent/vat-rates/exact"
      expect(response.status).to eq(303)
      expect(response).to redirect_to("/publish-intent/vat-rates")
    end
  end

  describe "deleting a publish intent" do
    let!(:intent) { create(:publish_intent, base_path: "/vat-rates") }

    context "when the user is not authenticated" do
      around do |example|
        ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
      end

      it "returns an unauthorized response" do
        delete "/publish-intent/vat-rates"

        expect(response).to be_unauthorized
      end
    end

    it "deletes the publish intent" do
      delete "/publish-intent/vat-rates"

      expect(PublishIntent.where(base_path: "/vat-rates").first).not_to be
    end

    it "returns 200" do
      delete "/publish-intent/vat-rates"

      expect(response.status).to eq(200)
    end

    it "returns 404 for non-existent intent" do
      delete "/publish-intent/non-existent"

      expect(response.status).to eq(404)
    end
  end
end
