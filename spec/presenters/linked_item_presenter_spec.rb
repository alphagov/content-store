require 'rails_helper'

describe LinkedItemPresenter do
  let(:api_url_method) do
    lambda { |base_path| "http://api.example.com/content/#{base_path}" }
  end

  describe "#present" do
    let(:content_item) do
      build(:content_item,
        content_id: 'AN-ID',
        title: "My Title",
        base_path: '/my-page',
        description: [
          { content_type: "text/html", content: "<p>A HTML description.</p>" },
          { content_type: "text/plain", content: "Short description." },
        ],
      )
    end

    let(:presenter) { LinkedItemPresenter.new(content_item, api_url_method) }

    subject(:presented_item) { presenter.present }

    it do
      is_expected.to eql({
        "content_id" => "AN-ID",
        "title" => "My Title",
        "base_path" => "/my-page",
        "description" => "<p>A HTML description.</p>",
        "api_url" => "http://api.example.com/content/my-page",
        "web_url" => "https://www.test.gov.uk/my-page",
        "locale" => "en",
        "links" => {},
      })
    end

    context "for a content item with an analytics_identifier" do
      before do
        content_item.analytics_identifier = "UA-123123"
      end

      it "includes the analytics_identifier" do
        expect(presented_item["analytics_identifier"]).to eq("UA-123123")
      end
    end

    context "for a content item with links" do
      before do
        content_item.links = {
          parent: [
            {
              content_id: "794cdd3c-6633-47b4-9e25-fe6a3aa96fa9",
              title: "The parent section",
              web_url: "/browse/parent-section",
            }
          ]
        }
      end

      it "adds one level of links" do
        expect(presented_item['links']).to eql(
          {
            parent: [
              {
                content_id: "794cdd3c-6633-47b4-9e25-fe6a3aa96fa9",
                title: "The parent section",
                web_url: "/browse/parent-section",
              }
            ]
          }
        )
      end
    end
  end
end
