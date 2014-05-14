require 'spec_helper'

describe "submitting an item to the content store" do
  before :each do
    @data = {
      "base_path" => "/vat-rates",
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "answer",
      "need_ids" => ["100123", "100124"],
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "details" => {
        "body" => "<p>Some body text</p>\n",
      },
    }
  end

  it "creates a content item when it doesn't already exist" do
    put_json "/content/vat-rates", @data

    expect(response.status).to eq(201)

    item = ContentItem.where(:base_path => "/vat-rates").first
    expect(item).to be
    expect(item.title).to eq("VAT rates")
    expect(item.description).to eq("Current VAT rates")
    expect(item.format).to eq("answer")
    expect(item.need_ids).to eq(["100123", "100124"])
    expect(item.public_updated_at).to eq(Time.zone.parse("2014-05-14T13:00:06Z"))
    expect(item.details).to eq({"body" => "<p>Some body text</p>\n"})
  end

  it "updates the relevant content item" do
    item = create(:content_item,
                  :base_path => "/vat-rates",
                  :need_ids => ["100321"],
                  :public_updated_at => Time.zone.parse("2014-03-12T14:53:54Z"),
                  :details => {"foo" => "bar"}
                 )
    put_json "/content/vat-rates", @data

    expect(response.status).to eq(200)

    item.reload
    expect(item.title).to eq("VAT rates")
    expect(item.need_ids).to eq(["100123", "100124"])
    expect(item.public_updated_at).to eq(Time.zone.parse("2014-05-14T13:00:06Z"))
    expect(item.details).to eq({"body" => "<p>Some body text</p>\n"})
  end

  it "does not allow updating the base_path of an item" do
    item = create(:content_item, :base_path => "/existing-path")
    @data["base_path"] = "/changed-path"
    put_json "/content/existing-path", @data

    item.reload
    expect(item.base_path).to eq("/existing-path")
  end

  it "returns a bad request when given invalid json" do
    put "/content/foo", "I'm not json", "CONTENT_TYPE" => "application/json"
    expect(response.status).to eq(400)
  end

  it "returns a validation error when given an invalid item" do
    @data["title"] = ""
    put_json "/content/vat-rates", @data

    expect(response.status).to eq(422)

    data = JSON.parse(response.body)
    expect(data["title"]).to eq("")
    expect(data["errors"]).to eq({"title" => ["can't be blank"]})
  end
end
