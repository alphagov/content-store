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
      let(:parent_section) {
        create(
          :content_item,
          content_id: SecureRandom.uuid,
          format: 'topic',
          title: 'The parent section',
          base_path: "/browse/parent-section",
        )
      }

      before do
        content_item.links = {
          parent: [
            {
              content_id: parent_section.content_id,
              title: parent_section.title,
              base_path: parent_section.base_path,
            }
          ]
        }
      end

      it "adds one level of links" do
        expect(presented_item['links']).to eql(
          parent: [
            {
              "content_id" => parent_section.content_id,
              "title" => parent_section.title,
              "base_path" => parent_section.base_path,
              "description" => parent_section.description,
              "api_url" => "http://api.example.com/content#{parent_section.base_path}",
              "web_url" => "https://www.test.gov.uk#{parent_section.base_path}",
              "locale" => parent_section.locale,
              "links" => {},
              "schema_name" => "topic",
              "document_type" => "topic",
            }
          ]
        )
      end
    end

    context "for a content item with linked topics" do
      let(:topic_business_tax) {
        create(
          :content_item,
          content_id: SecureRandom.uuid,
          format: 'topic',
          title: 'Business tax',
          base_path: "/topic/business-tax",
        )
      }

      let(:topic_paye) {
        create(
          :content_item,
          content_id: SecureRandom.uuid,
          format: 'topic',
          title: 'PAYE',
          base_path: "/topic/business-tax/paye",
          links: {
            parent: [topic_business_tax.content_id]
          }
        )
      }

      let(:topic_paye_details) {
        create(
          :content_item,
          content_id: SecureRandom.uuid,
          format: 'topic',
          title: 'PAYE details',
          base_path: "/topic/business-tax/paye/paye-details",
          links: {
            parent: [topic_paye.content_id]
          }
        )
      }

      context "single level" do
        before do
          content_item.links = {
            parent: [
              {
                content_id: topic_paye.content_id,
                title: topic_paye.title,
                base_path: topic_paye.base_path
              }
            ]
          }
        end

        it "adds grandparents" do
          expect(presented_item["links"]).to eql(
            parent: [
              {
                "content_id" => topic_paye.content_id,
                "title" => topic_paye.title,
                "base_path" => topic_paye.base_path,
                "description" => topic_paye.description,
                "api_url" => "http://api.example.com/content#{topic_paye.base_path}",
                "web_url" => "https://www.test.gov.uk#{topic_paye.base_path}",
                "locale" => topic_paye.locale,
                "schema_name" => "topic",
                "document_type" => "topic",
                "links" => {
                  "parent" => [
                    {
                      "content_id" => topic_business_tax.content_id,
                      "title" => topic_business_tax.title,
                      "base_path" => topic_business_tax.base_path,
                      "description" => topic_business_tax.description,
                      "api_url" => "http://api.example.com/content#{topic_business_tax.base_path}",
                      "web_url" => "https://www.test.gov.uk#{topic_business_tax.base_path}",
                      "locale" => topic_business_tax.locale,
                      "links" => {},
                      "schema_name" => "topic",
                      "document_type" => "topic",
                    }
                  ]
                }
              }
            ]
          )
        end

        context "deeply nested" do
          before do
            content_item.links = {
              parent: [
                {
                  content_id: topic_paye_details.content_id,
                  title: topic_paye_details.title,
                  base_path: topic_paye_details.base_path
                }
              ]
            }
          end

          it "adds nested parents" do
            expect(presented_item["links"]).to eql(
              parent: [
                "content_id" => topic_paye_details.content_id,
                "title" => topic_paye_details.title,
                "base_path" => topic_paye_details.base_path,
                "description" => topic_paye_details.description,
                "api_url" => "http://api.example.com/content#{topic_paye_details.base_path}",
                "web_url" => "https://www.test.gov.uk#{topic_paye_details.base_path}",
                "locale" => topic_paye_details.locale,
                "schema_name" => "topic",
                "document_type" => "topic",
                "links" => {
                  "parent" => [
                    {
                      "content_id" => topic_paye.content_id,
                      "title" => topic_paye.title,
                      "base_path" => topic_paye.base_path,
                      "description" => topic_paye.description,
                      "api_url" => "http://api.example.com/content#{topic_paye.base_path}",
                      "web_url" => "https://www.test.gov.uk#{topic_paye.base_path}",
                      "locale" => topic_paye.locale,
                      "schema_name" => "topic",
                      "document_type" => "topic",
                      "links" => {
                        "parent" => [
                          {
                            "content_id" => topic_business_tax.content_id,
                            "title" => topic_business_tax.title,
                            "base_path" => topic_business_tax.base_path,
                            "description" => topic_business_tax.description,
                            "api_url" => "http://api.example.com/content#{topic_business_tax.base_path}",
                            "web_url" => "https://www.test.gov.uk#{topic_business_tax.base_path}",
                            "locale" => topic_business_tax.locale,
                            "links" => {},
                            "schema_name" => "topic",
                            "document_type" => "topic",
                          }
                        ]
                      }
                    }
                  ]
                }
              ]
            )
          end
        end
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
