require 'spec_helper'

describe "Fetching a content item" do

  it "should return details for the requested item" do
    item = create(:content_item,
                 :base_path => "/vat-rates",
                 :title => "VAT rates",
                 :description => "Current VAT rates",
                 :format => "answer",
                 :need_ids => ["100136"],
                 :public_updated_at => 30.minutes.ago,
                 :details => {"body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n"}
                 )

    get "/content/vat-rates"

    expect(response).to be_success
    expect(response.content_type).to eq("application/json")

    data = JSON.parse(response.body)

    expect(data['base_path']).to eq('/vat-rates')
    expect(data['title']).to eq("VAT rates")
    expect(data['description']).to eq("Current VAT rates")
    expect(data['format']).to eq("answer")
    expect(data['need_ids']).to eq(["100136"])
    expect(data['public_updated_at']).to eq(item.public_updated_at.iso8601)
    expect(data['details']).to eq({"body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n"})

    expected_keys = ContentItem::PUBLIC_ATTRIBUTES
    expect(data.keys - expected_keys).to eq([])
  end

  it "should 404 for a non-existent item" do
    get "/content/non-existent"
    expect(response).to be_missing
  end
end
