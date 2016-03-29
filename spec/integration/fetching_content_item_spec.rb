require 'rails_helper'

describe "Fetching content items", type: :request do
  context "an existing content item" do
    let(:max_cache_time) { nil }

    let(:content_item) do
      FactoryGirl.create(
        :content_item,
        base_path: "/vat-rates",
        content_id: SecureRandom.uuid,
        title: "VAT rates",
        description: "Current VAT rates",
        format: "answer",
        need_ids: ["100136"],
        public_updated_at: 30.minutes.ago,
        details: { "body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n" },
        max_cache_time: max_cache_time,
      )
    end

    before do
      get_content content_item
    end

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
      data = JSON.parse(response.body)

      expect(data.keys).to match_array(%w[
        base_path
        content_id
        title
        description
        format
        need_ids
        locale
        analytics_identifier
        phase
        public_updated_at
        updated_at
        details
        links
      ])

      expect(data).to include(
        "base_path" => "/vat-rates",
        "content_id" => content_item.content_id,
        "title" => "VAT rates",
        "description" => "Current VAT rates",
        "format" => "answer",
        "need_ids" => ["100136"],
        "locale" => "en",
        "analytics_identifier" => nil,
        "phase" => "live",
      )
      expect(data["details"]).to eq("body" => "<div class=\"highlight-answer\">\n<p>The standard <abbr title=\"Value Added Tax\">VAT</abbr> rate is <em>20%</em></p>\n</div>\n",)
    end

    it "outputs the timestamp fields correctly" do
      content_item.reload # reload to pick up any time rounding in the database.

      data = JSON.parse(response.body)
      expect(data["public_updated_at"]).to eq(content_item.public_updated_at.as_json)
      expect(Time.parse(data["updated_at"])).to be_within(1.second).of(Time.now.utc)
    end

    it "sets cache headers to expire in the default TTL" do
      expect(cache_control["max-age"]).to eq(default_ttl.to_s)
    end

    it "sets a cache-control directive of public" do
      expect(cache_control["public"]).to eq(true)
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
    let(:content_item) { create(:content_item, base_path: URI.encode('/news/בוט לאינד')) }

    before(:each) { get_content content_item }

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "returns the presented content item as JSON data" do
      expect(response.content_type).to eq("application/json")
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

  context "a content item with linked items" do
    let(:content_item) { create(:content_item, links: { 'related' => [linked_item.content_id] }) }
    let(:linked_item) { create(:content_item, :with_content_id) }

    before(:each) { get_content content_item }

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "includes the correct data in the expanded representation of the linked item" do
      data = JSON.parse(response.body)

      linked_item_data = data["links"]["related"].first
      expect(linked_item_data.keys).to match_array(%w[
        base_path
        content_id
        title
        description
        locale
        api_url
        web_url
        links
      ])

      expect(linked_item_data).to include(
        "base_path" => linked_item.base_path,
        "content_id" => linked_item.content_id,
        "title" => linked_item.title,
        "description" => linked_item.description,
        "locale" => linked_item.locale,
        "web_url" => Plek.new.website_root + linked_item.base_path,
        "links" => {}
      )
    end

    it "correctly expands linked items with internal API URLs" do
      data = JSON.parse(response.body)

      expect(data["links"]["related"].first["api_url"]).to eq("http://www.example.com/content#{linked_item.base_path}")
    end
  end

  context "a content item with mixed linked items and passthrough hashes" do
    let(:content_item) {
      create(:content_item, links: {
        'related' => [
          linked_item.content_id,
          {
            content_id: "passthrough-content-id",
            title: "Passthrough title",
          }
        ]
      })
    }
    let(:linked_item) { create(:content_item, :with_content_id) }

    before(:each) { get_content content_item }

    it "returns a 200 OK response" do
      expect(response.status).to eq(200)
    end

    it "includes the correct data in the expanded representation of the linked items" do
      data = JSON.parse(response.body)

      data["links"]["related"].each do |linked_item_data|
        keys = linked_item_data.keys - %w[links] # links are optional
        expect(keys).to match_array(%w[
          base_path
          content_id
          title
          description
          locale
          api_url
          web_url
        ])
      end

      first_linked_item_data = data["links"]["related"].first
      expect(first_linked_item_data).to include(
        "base_path" => linked_item.base_path,
        "content_id" => linked_item.content_id,
        "title" => linked_item.title,
        "description" => linked_item.description,
        "locale" => linked_item.locale,
        "web_url" => Plek.new.website_root + linked_item.base_path,
      )

      second_linked_item_data = data["links"]["related"].second
      expect(second_linked_item_data).to include(
        "base_path" => nil,
        "content_id" => "passthrough-content-id",
        "title" => "Passthrough title",
        "description" => nil,
        "locale" => "en",
        "web_url" => nil,
      )
    end
  end
end
