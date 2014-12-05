require 'rails_helper'

describe "CRUD of publish intents", :type => :request do

  describe "submitting a publish intent" do
    let(:publish_time) { 40.minutes.from_now }
    let(:data) {{
      "base_path" => "/vat-rates",
      "publish_time" => publish_time,
    }}

    context "a new publish intent" do
      it "creates the publish intent" do
        put_json "/publish-intent/vat-rates", data

        intent = PublishIntent.where(:base_path => "/vat-rates").first
        expect(intent).to be
        expect(intent.publish_time).to match_datetime(publish_time)
      end

      it "responds with a created status, and the intent as json" do
        put_json "/publish-intent/vat-rates", data

        expect(response.status).to eq(201)

        data = JSON.parse(response.body)
        expect(data['base_path']).to eq('/vat-rates')
        expect(data['publish_time']).to match_datetime(publish_time)
      end
    end

    context "updating an existing publish intent" do
      let!(:intent) { create(:publish_intent, :base_path => "/vat-rates", :publish_time => 10.minutes.from_now) }

      it "updates the publish intent" do
        put_json "/publish-intent/vat-rates", data

        intent.reload
        expect(intent.publish_time).to match_datetime(publish_time)
      end

      it "responds with an ok status, and the intent as json" do
        put_json "/publish-intent/vat-rates", data

        expect(response.status).to eq(200)

        data = JSON.parse(response.body)
        expect(data['base_path']).to eq('/vat-rates')
        expect(data['publish_time']).to match_datetime(publish_time)
      end
    end

    it "handles non-ascii paths" do
      path = URI.encode('/news/בוט לאינד')
      put_json "/publish-intent#{path}", data.merge("base_path" => path)

      expect(response.status).to eq(201)

      data = JSON.parse(response.body)
      expect(data['base_path']).to eq(path)

      expect(PublishIntent.where(:base_path => path).first).to be
    end

    it "returns 422 and error details on validation error" do
      put_json "/publish-intent/vat-rates", data.merge("publish_time" => "")

      expect(response.status).to eq(422)

      data = JSON.parse(response.body)
      expect(data["errors"]).to eq({"publish_time" => ["can't be blank"]})

      expect(PublishIntent.where(:base_path => "/vat-rates").first).not_to be
    end

    it "returns 422 and an error message with extra fields in the input" do
      put_json "/publish-intent/vat-rates", data.merge("foo" => "bar", "bar" => "baz")

      expect(response.status).to eq(422)
      data = JSON.parse(response.body)
      expect(data["errors"]).to eq({"base" => ["unrecognised field(s) foo, bar in input"]})
    end

    it "returns a 400 with bad json" do
      put "/publish-intent/foo", "I'm not json", "CONTENT_TYPE" => "application/json"
      expect(response.status).to eq(400)
    end
  end

  describe "fetching details of a publish intent" do
    it "returns the intent details as json" do
      intent = create(:publish_intent, :base_path => "/vat-rates", :publish_time => 30.minutes.from_now)
      get "/publish-intent/vat-rates"
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")

      data = JSON.parse(response.body)
      expect(data['base_path']).to eq('/vat-rates')

      expect(data['publish_time']).to match_datetime(intent.publish_time)
    end

    it "handles non-ascii paths" do
      path = URI.encode('/news/בוט לאינד')
      intent = create(:publish_intent, :base_path => path)
      get "/publish-intent#{path}"
      expect(response.status).to eq(200)

      data = JSON.parse(response.body)
      expect(data['base_path']).to eq(path)
    end

    it "returns 404 for non-existent intent" do
      get "/publish-intent/non-existent"
      expect(response.status).to eq(404)
    end
  end

  describe "deleting a publish intent" do
    let!(:intent) { create(:publish_intent, :base_path => "/vat-rates") }

    it "deletes the publish intent" do
      delete "/publish-intent/vat-rates"

      expect(PublishIntent.where(:base_path => "/vat-rates").first).not_to be
    end

    it "returns 200 with details of the deleted intent" do
      delete "/publish-intent/vat-rates"

      expect(response.status).to eq(200)

      data = JSON.parse(response.body)
      expect(data['base_path']).to eq('/vat-rates')
      expect(data['publish_time']).to match_datetime(intent.publish_time)
    end

    it "returns 404 for non-existent intent" do
      delete "/publish-intent/non-existent"

      expect(response.status).to eq(404)
    end
  end
end
