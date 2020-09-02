require "rails_helper"
require "update_lock"

describe "content item write API", type: :request do
  before :each do
    @data = {
      "base_path" => "/vat-rates",
      "content_id" => SecureRandom.uuid,
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "answer",
      "schema_name" => "answer",
      "document_type" => "answer",
      "locale" => "en",
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "payload_version" => 1,
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "details" => {
        "body" => "<p>Some body text</p>\n",
      },
      "routes" => [
        { "path" => "/vat-rates", "type" => "exact" },
      ],
      "publishing_request_id" => "test test test",
    }
  end

  describe "creating a new content item" do
    context "when the user is not authenticated" do
      around do |example|
        ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
      end

      it "returns an unauthorized response" do
        put_json "/content/vat-rates", @data

        expect(response).to be_unauthorized
      end
    end

    it "responds with a CREATED status" do
      put_json "/content/vat-rates", @data
      expect(response.status).to eq(201)
    end

    it "creates the content item" do
      put_json "/content/vat-rates", @data
      item = ContentItem.where(base_path: "/vat-rates").first
      expect(item).to be
      expect(item.title).to eq("VAT rates")
      expect(item.description).to eq("Current VAT rates")
      expect(item.format).to eq("answer")
      expect(item.locale).to eq("en")
      expect(item.phase).to eq("live")
      expect(item.public_updated_at).to match_datetime("2014-05-14T13:00:06Z")
      expect(item.updated_at).to be_within(10.seconds).of(Time.zone.now)
      expect(item.details).to eq("body" => "<p>Some body text</p>\n")
      expect(item.publishing_request_id).to eq("test test test")
    end

    it "responds with an empty JSON document in the body" do
      put_json "/content/vat-rates", @data
      expect(response.body).to eq("{}")
    end

    it "registers routes for the content item" do
      put_json "/content/vat-rates", @data
      assert_routes_registered("frontend", [["/vat-rates", "exact"]])
    end

    context "with no content ID" do
      before :each do
        @data.delete "content_id"
      end

      it "responds with a CREATED status" do
        put_json "/content/vat-rates", @data
        expect(response.status).to eq(201)
      end
    end

    context "with multiple content types" do
      before do
        @data.merge!("description" => [
          { "content_type" => "text/html", "content" => "<p>content</p>" },
          { "content_type" => "text/plain", "content" => "content" },
        ])
      end

      it "creates the content item" do
        put_json "/content/vat-rates", @data
        expect(response.status).to eq(201)

        item = ContentItem.where(base_path: "/vat-rates").first
        expect(item.description).to eq [
          { "content_type" => "text/html", "content" => "<p>content</p>" },
          { "content_type" => "text/plain", "content" => "content" },
        ]
      end
    end

    context "with a publish intent in the past" do
      let(:publish_time) { 10.seconds.ago }
      let!(:publish_intent) do
        create(:publish_intent, base_path: @data["base_path"], publish_time: publish_time)
      end

      it "doesn't delete the publish intent" do
        put_json "/content/vat-rates", @data
        expect(PublishIntent.first).to eq(publish_intent)
      end

      it "logs the latency from the expected publish time" do
        put_json "/content/vat-rates", @data

        log_entry = ScheduledPublishingLogEntry.find_by(base_path: "/vat-rates")
        expect(log_entry.scheduled_publication_time.in_time_zone).to be_within(0.001.seconds).of(publish_time)
      end

      it "adds the latency to the content item" do
        put_json "/content/vat-rates", @data

        content_item = ContentItem.find_by(base_path: "/vat-rates")
        expect(content_item.publishing_scheduled_at.in_time_zone).to be_within(0.001.seconds).of(publish_time)
        expect(content_item.scheduled_publishing_delay_seconds).to_not be_nil
      end

      it "only logs the latency on the first publishing" do
        put_json "/content/vat-rates", @data
        expect(ScheduledPublishingLogEntry.where(base_path: "/vat-rates").count).to eq(1)

        put_json "/content/vat-rates", @data
        expect(ScheduledPublishingLogEntry.where(base_path: "/vat-rates").count).to eq(1)
      end

      it "does not log latency for 'coming soon' notices" do
        @data["document_type"] = "coming_soon"

        put_json "/content/vat-rates", @data
        expect(ScheduledPublishingLogEntry.count).to eq(0)
      end
    end

    context "with an earlier scheduled publishing" do
      it "logs the publishing delays for each scheduled publishing" do
        Timecop.freeze do
          first_scheduled_time = 2.days.ago.noon
          publish_intent = create(:publish_intent, base_path: @data["base_path"], publish_time: first_scheduled_time)
          put_json "/content/vat-rates", @data

          second_scheduled_time = 1.day.ago.noon
          publish_intent.publish_time = second_scheduled_time
          publish_intent.save!
          put_json "/content/vat-rates", @data

          log_entries = ScheduledPublishingLogEntry.where(base_path: "/vat-rates")
                                                   .order(scheduled_publication_time: :asc)
          expect(log_entries.count).to eq(2)

          expect(log_entries[0].scheduled_publication_time).to eq(first_scheduled_time)
          expect(log_entries[1].scheduled_publication_time).to eq(second_scheduled_time)
        end
      end
    end

    context "with a publish intent in the future" do
      let!(:publish_intent) do
        create(:publish_intent, base_path: @data["base_path"], publish_time: 1.hour.from_now)
      end

      it "doesn't delete the publish intent" do
        put_json "/content/vat-rates", @data
        expect(PublishIntent.first).to eq(publish_intent)
      end

      it "doesn't log the latency from the expected publish time" do
        put_json "/content/vat-rates", @data
        expect(ScheduledPublishingLogEntry.count).to eq(0)
      end
    end
  end

  context "with an earlier scheduled publishing log entry" do
    let(:publish_time) { 10.days.ago }
    let!(:log_entry) do
      Timecop.freeze(publish_time + 25.seconds) do
        create(
          :scheduled_publishing_log_entry,
          base_path: @data["base_path"],
          scheduled_publication_time: publish_time,
        )
      end
    end

    it "adds the latency to the content item" do
      put_json "/content/vat-rates", @data

      content_item = ContentItem.find_by(base_path: "/vat-rates")
      expect(content_item.publishing_scheduled_at.in_time_zone).to be_within(0.001.seconds).of(publish_time)
      expect(content_item.scheduled_publishing_delay_seconds).to be_between(24, 25).inclusive
    end
  end

  describe "creating a non-English content item" do
    it "creates the content item" do
      foreign_data = @data.merge(
        "title" => "Taux de TVA",
        "locale" => "fr",
        "base_path" => "/vat-rates.fr",
        "routes" => [
          { "path" => "/vat-rates.fr", "type" => "exact" },
        ],
      )

      put_json "/content/vat-rates.fr", foreign_data
      item = ContentItem.where(base_path: "/vat-rates.fr").first
      expect(item).to be
      expect(item.title).to eq("Taux de TVA")
      expect(item.locale).to eq("fr")
    end
  end

  describe "updating an existing content item" do
    let(:format) { "gone" }
    before(:each) do
      Timecop.travel(30.minutes.ago) do
        @item = create(
          :content_item,
          title: "Original title",
          base_path: "/vat-rates",
          format: format,
          public_updated_at: Time.zone.parse("2014-03-12T14:53:54Z"),
          details: { "foo" => "bar" },
        )
      end
      WebMock::RequestRegistry.instance.reset! # Clear out any requests made by factory creation.
    end

    it "responds with an OK status" do
      put_json "/content/vat-rates", @data
      expect(response.status).to eq(200)
    end

    it "updates the content item" do
      put_json "/content/vat-rates", @data
      @item.reload
      expect(@item.title).to eq("VAT rates")
      expect(@item.public_updated_at).to eq(Time.zone.parse("2014-05-14T13:00:06Z"))
      expect(@item.updated_at).to be_within(10.seconds).of(Time.zone.now)
      expect(@item.details).to eq("body" => "<p>Some body text</p>\n")
    end

    it "does not register routes when they haven't changed" do
      put_json "/content/vat-rates", @data
      refute_routes_registered("frontend", [["/vat-rates", "exact"]])
    end

    it "registers routes for the content item when they have changed" do
      @data["routes"] << { "path" => "/vat-rates.json", "type" => "exact" }
      put_json "/content/vat-rates", @data
      assert_routes_registered("frontend", [["/vat-rates", "exact"], ["/vat-rates.json", "exact"]])
    end

    context "when the original item is a placeholder" do
      let(:format) { "placeholder" }

      it "registers routes for the content item" do
        put_json "/content/vat-rates", @data
        assert_routes_registered("frontend", [["/vat-rates", "exact"]])
      end
    end

    context "when the router-api is unavailable" do
      let!(:stub) do
        stub_http_request(:post, "#{GdsApi::TestHelpers::Router::ROUTER_API_ENDPOINT}/routes/commit")
          .to_return(status: 500)
      end

      it "fails to update content item" do
        @data["routes"] << { "path" => "/vat-rates.json", "type" => "exact" }
        put_json "/content/vat-rates", @data
        @item.reload
        expect(@item.title).to eq("Original title")
        expect(WebMock::RequestRegistry.instance.times_executed(stub.request_pattern)).to eq(3)
      end
    end
  end

  describe "creating a content item with both routes and redirects" do
    before :each do
      @data["redirects"] = [
        { "path" => "/vat-rates.json", "type" => "exact", "destination" => "/api/content/vat-rates" },
      ]
    end

    it "registeres the routes and the redirects" do
      put_json "/content/vat-rates", @data
      assert_routes_registered("frontend", [["/vat-rates", "exact"]])
      assert_redirect_routes_registered([["/vat-rates.json", "exact", "/api/content/vat-rates"]])
    end
  end

  describe "creating an access-limited content item" do
    let(:authorised_users) { %w[a-user-identifier another-user-identifier] }
    before :each do
      @data["access_limited"] = {
        "users" => authorised_users,
      }
      put_json "/content/vat-rates", @data
    end

    it "saves the access-limiting details" do
      item = ContentItem.where(base_path: "/vat-rates").first
      expect(item).to be
      expect(item.access_limited).to eq("users" => authorised_users)
    end

    it "responds with CREATED and an empty JSON response" do
      expect(response.status).to eq(201)
      expect(response.body).to eq("{}")
    end
  end

  context "given invalid JSON data" do
    before(:each) do
      put "/content/foo", env: { "RAW_POST_DATA" => "I'm not json" }, headers: { "CONTENT_TYPE" => "application/json" }
    end

    it "returns a Bad Request status" do
      expect(response.status).to eq(400)
    end
  end

  context "create with extra fields in the input" do
    before :each do
      @data["foo"] = "bar"
      @data["bar"] = "baz"
      put_json "/content/vat-rates", @data
    end

    it "rejects the update" do
      expect(response.status).to eq(422)
    end

    it "includes an error message" do
      data = JSON.parse(response.body)
      expect(data["errors"]).to eq("base" => ["unrecognised field(s) foo, bar in input"])
    end
  end

  context "create with value of incorrect type" do
    before :each do
      @data["routes"] = 12
      put_json "/content/vat-rates", @data
    end

    it "rejects the update" do
      expect(response.status).to eq(422)
    end

    it "includes an error message" do
      data = JSON.parse(response.body)
      expected_error_message = Mongoid::Errors::InvalidValue.new(Array, @data["routes"].class).message
      expect(data["errors"]).to eq("base" => [expected_error_message])
    end
  end

  context "copes with non-ASCII paths" do
    # rubocop:disable Style/AsciiComments
    # URI.escape("/news/בוט לאינד")
    # rubocop:enable Style/AsciiComments
    let(:path) { "/news/%D7%91%D7%95%D7%98%20%D7%9C%D7%90%D7%99%D7%A0%D7%93" }

    before :each do
      @data["base_path"] = path
      @data["routes"][0]["path"] = path
    end

    it "should accept a request with non-ASCII path" do
      put_json "/content/#{path}", @data
      expect(response.status).to eq(201)
    end

    it "creates the item with encoded base_path" do
      put_json "/content/#{path}", @data
      item = ContentItem.where(base_path: path).first
      expect(item).to be
      expect(item.base_path).to eq(path)
    end
  end

  context "with stale attributes" do
    before do
      create(
        :content_item,
        base_path: "/vat-rates",
        payload_version: "2",
      )
    end

    context "payload_version based" do
      before do
        put_json "/content/vat-rates", @data
      end

      it "responds with a HTTP 'conflict' status" do
        expect(response.status).to eq(409)
      end

      it "provides a helpful error body" do
        expect(response.body).to include(
          "the latest ContentItem has a newer (or equal) payload_version of 2",
        )
      end

      it "doesn't perform an update" do
        content_item = ContentItem.where(base_path: "/vat-rates").first
        expect(content_item.payload_version).to eq(2)
      end
    end
  end

  context "without payload_version" do
    before do
      create(
        :content_item,
        base_path: "/vat-rates",
        payload_version: "1",
      )
    end

    it "raises a MissingAttributeError" do
      expect {
        put_json "/content/vat-rates",
                 @data.to_h.except(
                   "payload_version",
                 )
      }.to raise_error(MissingAttributeError)
    end
  end
end
