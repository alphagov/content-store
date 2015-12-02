require 'rails_helper'

describe LinkedItemPresenter do
  let(:api_url_method) do
    lambda { |base_path| "http://api.example.com/content/#{base_path}" }
  end

  describe "#present" do
    it "presents the correct data" do
      content_item = create(:content_item,
        content_id: 'AN-ID',
        title: "My Title",
        base_path: '/my-page',
        description: [
          { content_type: "text/html", content: "<p>A HTML description.</p>" },
          { content_type: "text/plain", content: "Short description." },
        ],
      )

      presenter = LinkedItemPresenter.new(content_item, api_url_method)

      expect(presenter.present).to eql({
        "content_id" => "AN-ID",
        "title" => "My Title",
        "base_path" => "/my-page",
        "description" => "<p>A HTML description.</p>",
        "api_url" => "http://api.example.com/content/my-page",
        "web_url" => "https://www.test.gov.uk/my-page",
        "locale" => "en"
      })
    end

    it "adds the analytics identifier if present" do
      content_item = create(:content_item,
        analytics_identifier: 'UA-123123',
      )

      presenter = LinkedItemPresenter.new(content_item, api_url_method)

      expect(presenter.present['analytics_identifier']).to eql('UA-123123')
    end
  end
end
