require "rails_helper"

describe "Fetching content items", type: :request do
  context "an existing content item" do
    let(:max_cache_time) { nil }

    let(:content_item) do
      FactoryBot.create(
        :content_item,
        base_path: "/vat-rates",
        content_id: SecureRandom.uuid,
        title: "VAT rates",
        description: "Current VAT rates",
        format: "publication",
        schema_name: "publication",
        document_type: "travel_advice",
        public_updated_at: 30.minutes.ago,
        details: {
          "body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n",
          "max_cache_time" => max_cache_time,
        },
      )
    end

    before do
      get "/content#{content_item.base_path}"
    end

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "returns the presented content item as JSON data" do
      expect(response.media_type).to eq("application/json")
      data = JSON.parse(response.body)

      expect(data.keys).to match_array(%w[
        base_path
        content_id
        title
        description
        schema_name
        document_type
        locale
        analytics_identifier
        phase
        first_published_at
        public_updated_at
        publishing_scheduled_at
        scheduled_publishing_delay_seconds
        updated_at
        rendering_app
        publishing_app
        details
        links
        withdrawn_notice
        publishing_request_id
      ])

      expect(data).to include(
        "base_path" => "/vat-rates",
        "content_id" => content_item.content_id,
        "title" => "VAT rates",
        "description" => "Current VAT rates",
        "schema_name" => "publication",
        "document_type" => "travel_advice",
        "locale" => "en",
        "analytics_identifier" => nil,
        "phase" => "live",
      )
      expect(data["details"]).to eq(
        "body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n",
        "max_cache_time" => nil,
      )
    end

    it "outputs the timestamp fields correctly" do
      content_item.reload # reload to pick up any time rounding in the database.

      data = JSON.parse(response.body)
      expect(data["public_updated_at"]).to eq(content_item.public_updated_at.as_json)
      expect(Time.zone.parse(data["updated_at"])).to be_within(1.second).of(Time.zone.now.utc)
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end

    context "when the user is not authenticated" do
      around do |example|
        ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
      end

      it "returns an unauthorized response" do
        expect(response).to be_successful
      end
    end

    context "when the max_cache_time field is set on the content item" do
      let(:max_cache_time) { 123 }

      it "sets cache headers to expire in the max_cache_time" do
        expect(cache_control["max-age"]).to eq(123.to_s)
      end

      context "but the max_cache_time exceeds the default TTL" do
        let(:max_cache_time) { default_ttl + 999 }

        it "disregards the max_cache_time" do
          expect(cache_control["max-age"]).to eq(default_ttl.to_s)
        end
      end

      context "and it is zero" do
        let(:max_cache_time) { 0 }

        it "sets cache headers to expire in the minimum_ttl" do
          expect(cache_control["max-age"]).to eq(minimum_ttl.to_s)
        end
      end
    end
  end

  context "a content item with a non-ASCII base_path" do
    # rubocop:disable Style/AsciiComments
    # URI.escape("/news/בוט לאינד")
    # rubocop:enable Style/AsciiComments
    path = "/news/%D7%91%D7%95%D7%98%20%D7%9C%D7%90%D7%99%D7%A0%D7%93"
    let(:content_item) { create(:content_item, base_path: path) }

    before(:each) { get "/content#{content_item.base_path}" }

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "returns the presented content item as JSON data" do
      expect(response.media_type).to eq("application/json")
      expect(response.body).to eq(present(content_item))
    end
  end

  context "a non-existent content item" do
    before(:each) { get "/content/does/not/exist" }

    it "returns a 404 Not Found response" do
      expect(response.status).to eq(404)
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end

  context "when requesting an exact route within a base_path" do
    let!(:content_item) do
      FactoryBot.create(
        :content_item,
        base_path: "/base-path",
        content_id: SecureRandom.uuid,
        routes: [
          { path: "/base-path/exact", type: "exact" },
        ],
      )
    end

    let(:requested_path) { "/base-path/exact" }
    let(:colliding_path) { "/does-not-collide" }

    let!(:colliding_content_item) do
      FactoryBot.create(
        :content_item,
        base_path: colliding_path,
        content_id: SecureRandom.uuid,
      )
    end

    before do
      get "/content#{requested_path}"
    end

    it "returns a 303 See Other response" do
      expect(response.status).to eq(303)
    end

    it "returns a redirect to the item by base_path" do
      expect(response).to redirect_to("/content/base-path")
    end

    context "and a different content item has the base_path of the route" do
      let(:colliding_path) { "/base-path/exact" }
      it "returns the colliding content item" do
        expect(response.media_type).to eq("application/json")
        expect(response.body).to eq(present(colliding_content_item))
      end
    end
  end

  shared_examples "redirecting prefix routes" do
    let(:requested_path) { "/base-path/prefix" }

    before do
      get "/content#{requested_path}"
    end

    it "returns a 303 See Other response" do
      expect(response.status).to eq(303)
    end

    it "returns a redirect to the item by base_path" do
      expect(response).to redirect_to("/content/base-path")
    end

    context "and we request a route within the prefix" do
      let(:requested_path) { "/base-path/prefix/deeply/nested/path" }

      it "returns a redirect to the item by base_path" do
        expect(response).to redirect_to("/content/base-path")
      end
    end
  end

  context "when requesting a prefix route within a base_path" do
    before do
      FactoryBot.create(
        :content_item,
        base_path: "/base-path",
        content_id: SecureRandom.uuid,
        routes: [
          { path: "/base-path/prefix", type: "prefix" },
        ],
      )
    end

    include_examples "redirecting prefix routes"
  end

  context "when requesting a prefix redirect within a base_path" do
    before do
      FactoryBot.create(
        :redirect_content_item,
        base_path: "/base-path",
        content_id: SecureRandom.uuid,
        redirects: [
          { path: "/base-path/prefix", type: "prefix", "destination" => "/somewhere" },
        ],
      )
    end

    include_examples "redirecting prefix routes"
  end

  context "a withdrawn content item" do
    let(:withdrawn_at) { Time.zone.parse("2016-05-17 11:20") }
    let(:withdrawn_item) do
      FactoryBot.create(
        :content_item,
        withdrawn_notice: {
          explanation: "This is no longer true",
          withdrawn_at: withdrawn_at,
        },
      )
    end

    it "displays the withdrawal explanation and time" do
      get "/content#{withdrawn_item.base_path}"

      data = JSON.parse(response.body)

      expect(data["withdrawn_notice"]["explanation"]).to eq("This is no longer true")
      expect(Time.iso8601(data["withdrawn_notice"]["withdrawn_at"])).to eq(withdrawn_at)
    end
  end

  context "a gone content item" do
    let(:gone_item) { FactoryBot.create(:gone_content_item) }

    before do
      get "/content#{gone_item.base_path}"
    end

    it "responds with 410" do
      expect(response.status).to eq(410)
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
    end
  end

  context "a gone content item with an explantion and alternative_path" do
    let(:gone_item) { FactoryBot.create(:gone_content_item_with_details) }

    before do
      get "/content#{gone_item.base_path}"
    end

    it "responds with 200" do
      expect(response.status).to eq(200)
    end

    it "includes the details" do
      details = JSON.parse(response.body)["details"]
      expect(details["explanation"]).to eq("<div class=\"govspeak\"><p>Explanation…</p> </div>")
      expect(details["alternative_path"]).to eq("/example")
    end
  end
end
