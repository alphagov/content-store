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
  end
end
