require 'rails_helper'

describe ContentItemPresenter do
  let(:expanded_links) do
    {
      "parent" => [
        {
          "base_path" => "/foo",
          "title" => "foo",
        },
        {
          "base_path" => "/bar",
          "title" => "bar",
        }
      ]
    }
  end
  let(:item) { build(:content_item, document_type: "travel_advice", links: links, locale: locale, expanded_links: expanded_links) }
  let(:links) { {} }
  let(:locale) { "en" }

  let(:api_url_method) do
    lambda { |base_path| "http://api.example.com/content/#{base_path}" }
  end
  let(:presenter) { ContentItemPresenter.new(item, api_url_method) }

  it "includes public attributes" do
    expected_fields = ContentItemPresenter::PUBLIC_ATTRIBUTES + %w(links description details)
    expect(presenter.as_json.keys).to match_array(expected_fields)
  end

  it "outputs the base_path correctly" do
    expect(presenter.as_json["base_path"]).to eq(item.base_path)
  end

  describe "content type resolution" do
    let(:item) do
      FactoryBot.create(
        :content_item,
        links: links,
        description: [
          { content_type: "text/html", content: "<p>content</p>" },
          { content_type: "text/plain", content: "content" },
        ],
        details: {
          body: [
            { content_type: "text/html", content: "<p>content</p>" },
            { content_type: "text/plain", content: "content" },
          ],
        }
      )
    end

    it "inlines the 'text/html' content type in the description" do
      expect(presenter.as_json["description"]).to eq("<p>content</p>")
    end

    it "inlines the 'text/html' content type in the details" do
      expect(presenter.as_json["details"]).to eq(body: "<p>content</p>")
    end
  end

  it "validates against the schema" do
    content_item = create(:content_item, :with_content_id, schema_name: "generic")

    presented = ContentItemPresenter.new(content_item, api_url_method).as_json

    expect(presented.to_json).to be_valid_against_schema("generic")
  end

  context "when schema_name is not redirect" do
    it "doesn't include redirects field" do
      content_item = create(:content_item)
      presented = ContentItemPresenter.new(content_item, api_url_method).as_json
      expect(presented.keys).to_not include("redirects")
    end
  end

  context "when schema_name is redirect" do
    it "includes the redirects field" do
      content_item = create(:redirect_content_item)
      presented = ContentItemPresenter.new(content_item, api_url_method).as_json
      expect(presented.keys).to include("redirects")
    end
  end

  context "when the document was not published by the scheduler" do
    it "does not include a scheduled publication date" do
      content_item = create(:content_item)
      presented = ContentItemPresenter.new(content_item, api_url_method).as_json
      expect(presented["publishing_scheduled_at"]).to be_nil
    end
  end

  context "when the document was published by the scheduler" do
    it "includes scheduled publication date and delay" do
      content_item = create(:content_item)
      scheduled_publishing = Timecop.freeze(Time.new(2018, 3, 1, 9, 32)) do
        create(:scheduled_publishing_log_entry,
          scheduled_publication_time: Time.new(2018, 3, 1, 9, 30))
      end

      presented = ContentItemPresenter.new(content_item, api_url_method, scheduled_publishing: scheduled_publishing).as_json

      expect(presented["publishing_scheduled_at"]).to eq(scheduled_publishing.scheduled_publication_time)
      expect(presented["scheduled_publishing_delay_seconds"]).to eq(120)
    end

    it "validates against the schema" do
      content_item = create(:content_item, :with_content_id, schema_name: "generic")
      scheduled_publishing = create(:scheduled_publishing_log_entry)
      presented = ContentItemPresenter.new(content_item, api_url_method, scheduled_publishing: scheduled_publishing).as_json
      expect(presented.to_json).to be_valid_against_schema("generic")
    end
  end
end
