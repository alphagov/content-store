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
      expect(data['locale']).to eq("en")
      expect(data['updated_at']).to match_datetime(item.updated_at)
      expect(data['public_updated_at']).to match_datetime(item.public_updated_at)
      expect(data['details']).to eq({"body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n"})

      expected_keys = PublicContentItemPresenter::PUBLIC_ATTRIBUTES + ["links"]
      expect(data.keys).to match_array(expected_keys)
    end

    it "should not return the content ID" do
      get "/content/vat-rates"
      data = JSON.parse(response.body)
      expect(data).not_to have_key("content_id")
    end

    describe "setting cache headers" do
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

      describe "adjusting expiry for publish intents" do
        it "should set the Expires header to the date of the upcoming publish_intent" do
          Timecop.freeze do
            create(:publish_intent, :base_path => "/vat-rates", :publish_time => 23.minutes.from_now)
            get "/content/vat-rates"
            expect(response.headers["Expires"]).to eq(23.minutes.from_now.httpdate)
          end
        end

        it "should set the Expires header to 30 mins with publish_intent more than 30 mins away" do
          Timecop.freeze do
            create(:publish_intent, :base_path => "/vat-rates", :publish_time => 40.minutes.from_now)
            get "/content/vat-rates"
            expect(response.headers["Expires"]).to eq(30.minutes.from_now.httpdate)
          end
        end

        it "should set the Expires header to 30 mins with a publish_intent in the past" do
          Timecop.freeze do
            create(:publish_intent, :base_path => "/vat-rates", :publish_time => 10.minutes.ago)
            get "/content/vat-rates"
            expect(response.headers["Expires"]).to eq(30.minutes.from_now.httpdate)
          end
        end

        it "should set an Expires header in the past with a publish_intent that's very recently in the past" do
          Timecop.freeze do
            create(:publish_intent, :base_path => "/vat-rates", :publish_time => 10.seconds.ago)
            get "/content/vat-rates"
            expect(response.headers["Expires"]).to eq(10.seconds.ago.httpdate)
          end
        end
      end
    end

    describe "expanding linked items" do
      # functional behaviour of link expansion covered in end_to_end_spec

      it "does not use N+1 queries to expand linked items" do
        item.links["related"] = []
        20.times do
          linked_item = create(:content_item, :with_content_id)
          item.links["related"] << linked_item.content_id
        end
        item.save!
        reset_mongoid_query_count

        get "/content#{item.base_path}"

        # 5 chosen as a reasonable threshold with a little headroom.
        expect(mongoid_query_count).to be <= 5
      end

      it "does not use N+1 queries to expand translations" do
        I18n.available_locales.each do |locale|
          next if locale == :en
          create(:content_item, :content_id => item.content_id, :locale => locale.to_s)
        end
        reset_mongoid_query_count

        get "/content#{item.base_path}"

        # 5 chosen as a reasonable threshold with a little headroom.
        expect(mongoid_query_count).to be <= 5
      end
    end
  end

  describe "handling non-existent entries" do
    it "should 404 for a non-existent item" do
      get "/content/non-existent"
      expect(response.status).to eq(404)
    end

    it "should set cache headers" do
      Timecop.freeze do
        get "/content/non-existent"
        expect(response.headers["Expires"]).to eq(30.minutes.from_now.httpdate)
        expect(response.headers["Cache-Control"]).to eq('public')
      end
    end

    describe "adjusting expiry for publish intents" do
      it "should set the Expires header to the date of the upcoming publish_intent" do
        Timecop.freeze do
          create(:publish_intent, :base_path => "/non-existent", :publish_time => 23.minutes.from_now)
          get "/content/non-existent"
          expect(response.headers["Expires"]).to eq(23.minutes.from_now.httpdate)
        end
      end

      it "should set the Expires header to 30 mins with publish_intent more than 30 mins away" do
        Timecop.freeze do
          create(:publish_intent, :base_path => "/non-existent", :publish_time => 40.minutes.from_now)
          get "/content/non-existent"
          expect(response.headers["Expires"]).to eq(30.minutes.from_now.httpdate)
        end
      end

      it "should set the Expires header to 30 mins with a publish_intent in the past" do
        Timecop.freeze do
          create(:publish_intent, :base_path => "/non-existent", :publish_time => 10.minutes.ago)
          get "/content/non-existent"
          expect(response.headers["Expires"]).to eq(30.minutes.from_now.httpdate)
        end
      end

      it "should set an Expires header in the past with a publish_intent that's very recently in the past" do
        Timecop.freeze do
          create(:publish_intent, :base_path => "/non-existent", :publish_time => 10.seconds.ago)
          get "/content/non-existent"
          expect(response.headers["Expires"]).to eq(10.seconds.ago.httpdate)
        end
      end
    end
  end

  it "returns an item with a non-ASCII path" do
    path = URI.encode('/news/בוט לאינד')
    create(:content_item,
     :base_path => path,
     :content_id => SecureRandom.uuid,
     :title => "VAT rates",
     :description => "Current VAT rates",
     :format => "answer",
     :need_ids => ["100136"],
     :public_updated_at => 30.minutes.ago,
     :details => {"body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n"})
    get "/content/#{path}"
    data = JSON.parse(response.body)
    expect(data['title']).to eq("VAT rates")
  end
end
