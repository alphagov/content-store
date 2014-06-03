require 'spec_helper'

describe "content item write API" do
  before :each do
    @data = {
      "base_path" => "/vat-rates",
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "answer",
      "need_ids" => ["100123", "100124"],
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "rendering_app" => "frontend",
      "details" => {
        "body" => "<p>Some body text</p>\n",
      },
      "routes" => [
        { "path" => "/vat-rates", "type" => 'exact' }
      ],
    }
  end

  context "creating a new content item" do
    before(:each) do
      put_json "/content/vat-rates", @data
    end

    it "responds with a CREATED status" do
      expect(response.status).to eq(201)
    end

    it "creates the content item" do
      item = ContentItem.where(:base_path => "/vat-rates").first
      expect(item).to be
      expect(item.title).to eq("VAT rates")
      expect(item.description).to eq("Current VAT rates")
      expect(item.format).to eq("answer")
      expect(item.need_ids).to eq(["100123", "100124"])
      expect(item.public_updated_at).to eq(Time.zone.parse("2014-05-14T13:00:06Z"))
      expect(item.details).to eq({"body" => "<p>Some body text</p>\n"})
    end

    it "responds with the content item as JSON in the body" do
      item = ContentItem.where(:base_path => "/vat-rates").first
      response_data = JSON.parse(response.body)

      expect(response_data["title"]).to eq(item.title)
    end

    it "registers routes for the content item" do
      assert_routes_registered([['/vat-rates', 'exact', 'frontend']])
    end
  end

  context 'updating an existing content item' do
    before(:each) do
      @item = create(:content_item,
                     :base_path => "/vat-rates",
                     :need_ids => ["100321"],
                     :public_updated_at => Time.zone.parse("2014-03-12T14:53:54Z"),
                     :details => {"foo" => "bar"}
                    )

      put_json "/content/vat-rates", @data
    end

    it "responds with an OK status" do
      expect(response.status).to eq(200)
    end

    it "updates the content item" do
      @item.reload
      expect(@item.title).to eq("VAT rates")
      expect(@item.need_ids).to eq(["100123", "100124"])
      expect(@item.public_updated_at).to eq(Time.zone.parse("2014-05-14T13:00:06Z"))
      expect(@item.details).to eq({"body" => "<p>Some body text</p>\n"})
    end

    it "responds with the content item as JSON in the body" do
      @item.reload
      response_data = JSON.parse(response.body)
      expect(response_data["title"]).to eq(@item.title)
    end

    it "updates routes for the content item" do
      assert_routes_registered([['/vat-rates', 'exact', 'frontend']], 2)
    end
  end

  context "given invalid JSON data" do
    before(:each) do
      put "/content/foo", "I'm not json", "CONTENT_TYPE" => "application/json"
    end

    it "returns a Bad Request status" do
      expect(response.status).to eq(400)
    end
  end

  context "given a partial update" do
    before(:each) do
      @item = create(:content_item, :base_path => "/vat-rates")

      put_json "/content/vat-rates", @data.except("title")
    end

    it "returns a Unprocessable Entity status" do
      expect(response.status).to eq(422)
    end

    it "includes validation error messages in the response" do
      data = JSON.parse(response.body)
      expect(data["errors"]).to eq({"title" => ["can't be blank"]})
    end
  end

  context "create with an invalid content item" do
    before(:each) do
      @data["title"] = ""
      put_json "/content/vat-rates", @data
    end

    it "returns a Unprocessable Entity status" do
      expect(response.status).to eq(422)
    end

    it "includes validation error messages in the response" do
      data = JSON.parse(response.body)
      expect(data["title"]).to eq("")
      expect(data["errors"]).to eq({"title" => ["can't be blank"]})
    end
  end
end
