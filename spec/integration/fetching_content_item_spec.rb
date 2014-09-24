require 'rails_helper'

describe "Fetching a content item", :type => :request do

  context "valid request" do
    let!(:item) {
      create(:content_item,
       :base_path => "/vat-rates",
       :content_id => SecureRandom.uuid,
       :title => "VAT rates",
       :description => "Current VAT rates",
       :format => "answer",
       :need_ids => ["100136"],
       :public_updated_at => 30.minutes.ago,
       :details => {"body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n"})
      .reload # Necessary to avoid rounding errors with timestamps etc.
    }

    it "should return details for the requested item" do
      get "/content/vat-rates"

      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")

      data = JSON.parse(response.body)

      expect(data['base_path']).to eq('/vat-rates')
      expect(data['title']).to eq("VAT rates")
      expect(data['description']).to eq("Current VAT rates")
      expect(data['format']).to eq("answer")
      expect(data['need_ids']).to eq(["100136"])
      expect(data['updated_at']).to eq(item.updated_at.as_json)
      expect(data['public_updated_at']).to eq(item.public_updated_at.as_json)
      expect(data['details']).to eq({"body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n"})

      expected_keys = PublicContentItemPresenter::PUBLIC_ATTRIBUTES
      expect(data.keys - expected_keys).to eq([])
    end

    it "should set a 30 minutes Expires header in response" do
      Timecop.freeze do
        get "/content/vat-rates"
        expect(response.headers["Expires"]).to eq(30.minutes.from_now.httpdate)
      end
    end

    it "should set a cache-control header with value public" do
      get "/content/vat-rates"
      expect(response.headers["Cache-Control"]).to eq('public')
    end

    it "should not return the content ID" do
      get "/content/vat-rates"
      data = JSON.parse(response.body)
      expect(data).not_to include("content_id")
    end
  end

  it "should 404 for a non-existent item" do
    get "/content/non-existent"
    expect(response.status).to eq(404)
  end

end
