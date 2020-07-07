require "rails_helper"
require "tasks/data_hygiene/inconsistent_redirect_finder"

describe Tasks::DataHygiene::InconsistentRedirectFinder do
  describe "#items_with_inconsistent_redirects" do
    it "returns items that redirect in the router" do
      stub_router(path: "/path-with-redirect-route", status: 200, body: { handler: "redirect" })
      content_item = create(:content_item, base_path: "/path-with-redirect-route")

      found_items = find_inconsistent_redirects([content_item])

      expect(found_items).to eql([content_item])
    end

    it "doesn't return items that are redirects themselves" do
      content_item = create(:redirect_content_item)

      found_items = find_inconsistent_redirects([content_item])

      expect(found_items).to be_empty
    end

    it "doesn't return items that don't have a route, like most of Whitehall's content" do
      stub_router(path: "/some-path-without-route", status: 404, body: {})
      content_item = create(:content_item, base_path: "/some-path-without-route")

      found_items = find_inconsistent_redirects([content_item])

      expect(found_items).to be_empty
    end

    it "only returns redirects" do
      stub_router(path: "/path-with-not-a-redirect-route", status: 200, body: { handler: "not-redirect" })
      content_item = create(:content_item, base_path: "/path-with-not-a-redirect-route")

      found_items = find_inconsistent_redirects([content_item])

      expect(found_items).to be_empty
    end

    def find_inconsistent_redirects(content_items)
      Tasks::DataHygiene::InconsistentRedirectFinder.new(content_items).items_with_inconsistent_redirects
    end

    def stub_router(path:, status:, body:)
      stub_request(:get, "#{Plek.find('router-api')}/routes?incoming_path=#{path}")
        .to_return(status: status, body: body.to_json)
    end
  end
end
