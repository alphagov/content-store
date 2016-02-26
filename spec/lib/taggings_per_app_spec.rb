require 'rails_helper'
require 'taggings_per_app'

describe TaggingsPerApp do
  describe "#taggings" do
    it "returns taggings of the content items for an application" do
      create(:content_item, content_id: '42de1d3f-5d73-48d2-bc0d-5317c330f21b', publishing_app: 'publisher')
      create(:content_item,
        content_id: 'bbcaf28a-1784-4d30-b6be-f4db4089432c',
        publishing_app: 'smartanswers',
        links: {
          "mainstream_browse_pages" => ["56d4ec50-e0ad-44bd-8b49-4d47ddf68a24"]
        }
            )

      taggings = TaggingsPerApp.new('smartanswers').taggings

      expect(taggings).to eql(
        'bbcaf28a-1784-4d30-b6be-f4db4089432c' => {
  "mainstream_browse_pages" => ['56d4ec50-e0ad-44bd-8b49-4d47ddf68a24']
}
      )
    end

    it "does not return unrenderable items like redirects" do
      renderable = create(:content_item, content_id: SecureRandom.uuid, format: 'topic', publishing_app: 'publisher')
      redirect = create(:content_item, content_id: SecureRandom.uuid, format: 'redirect', publishing_app: 'publisher')

      taggings = TaggingsPerApp.new('publisher').taggings

      expect(taggings.keys).to include(renderable.content_id)
      expect(taggings.keys).not_to include(redirect.content_id)
    end
  end
end
