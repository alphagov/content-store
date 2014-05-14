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

  it "does not allow updating the base_path of an item"

  it "returns a bad request when given invalid json"

  it "returns a validation error when given an invalid item"
end
