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
              schema_name: 'publication',
              document_type: 'policy_paper',
              description: [
                { content_type: "text/html", content: "<p>A HTML description.</p>" },
                { content_type: "text/plain", content: "Short description." },
              ],
              public_updated_at: Time.new(2016, 1, 1)
           )
    end

    let(:presenter) { LinkedItemPresenter.new(content_item, api_url_method) }

    subject(:presented_item) { presenter.present }

    it do
      is_expected.to eql(
        "content_id" => "AN-ID",
        "title" => "My Title",
        "base_path" => "/my-page",
        "description" => "<p>A HTML description.</p>",
        "api_url" => "http://api.example.com/content/my-page",
        "web_url" => "https://www.test.gov.uk/my-page",
        "locale" => "en",
        "links" => {},
        "public_updated_at" => DateTime.new(2016, 1, 1),
        "schema_name" => "publication",
        "document_type" => "policy_paper"
      )
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
          parent: [
            {
              content_id: "794cdd3c-6633-47b4-9e25-fe6a3aa96fa9",
              title: "The parent section",
              web_url: "/browse/parent-section",
            }
          ]
        )
      end
    end

    context "with a topical_event link" do
      let(:content_item) do
        build(:content_item, document_type: "topical_event", details: {
          start_date: "2015-11-25T00:00:00.000+00:00",
          end_date: "2015-11-30T00:00:00.000+00:00",
        })
      end

      it "adds the start and end date from the details hash" do
        expect(presented_item['details']).to eql(
          "start_date" => "2015-11-25T00:00:00.000+00:00",
          "end_date" => "2015-11-30T00:00:00.000+00:00",
        )
      end
    end

    # TODO: Remove when topical_events are migrated
    context "with a placeholder_topical_event link" do
      let(:content_item) do
        build(:content_item, document_type: "placeholder_topical_event", details: {
          start_date: "2015-11-25T00:00:00.000+00:00",
          end_date: "2015-11-30T00:00:00.000+00:00",
        })
      end

      it "adds the start and end date from the details hash" do
        expect(presented_item['details']).to eql(
          "start_date" => "2015-11-25T00:00:00.000+00:00",
          "end_date" => "2015-11-30T00:00:00.000+00:00",
        )
      end
    end

    context "with an organisation link" do
      let(:content_item) do
        build(:content_item, document_type: "organisation", details: {
          brand: "ministry-mcministryface",
          logo: {
            formatted_title: "Ministry<br/>McMinistryface",
            crest: "mmmf"
          }
        })
      end

      it "adds the start and end date from the details hash" do
        expect(presented_item['details']).to eql(
          "brand" => "ministry-mcministryface",
          "logo" => {
            "formatted_title" => "Ministry<br/>McMinistryface",
            "crest" => "mmmf"
          }
        )
      end
    end

    context "with a placeholder_organisation link" do
      let(:content_item) do
        build(:content_item, document_type: "placeholder_organisation", details: {
          brand: "ministry-mcministryface",
          logo: {
            formatted_title: "Ministry<br/>McMinistryface",
            crest: "mmmf"
          }
        })
      end

      it "adds the start and end date from the details hash" do
        expect(presented_item['details']).to eql(
          "brand" => "ministry-mcministryface",
          "logo" => {
            "formatted_title" => "Ministry<br/>McMinistryface",
            "crest" => "mmmf"
          }
        )
      end
    end
  end
end
