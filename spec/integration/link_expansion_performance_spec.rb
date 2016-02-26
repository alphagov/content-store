require 'rails_helper'

describe "Fetching content items", type: :request do
  it "does not use N+1 queries to expand linked items" do
    content_item = create(:content_item)
    content_item.links["related"] = []
    20.times do
      linked_item = create(:content_item, :with_content_id)
      content_item.links["related"] << linked_item.content_id
    end
    content_item.save!

    reset_mongoid_query_count

    get_content content_item

    # 5 chosen as a reasonable threshold with a little headroom.
    expect(mongoid_query_count).to be <= 5
  end

  it "does not use N+1 queries to expand translations" do
    content_item = create(:content_item, :with_content_id)
    I18n.available_locales.each do |locale|
      next if locale == :en
      create(:content_item, content_id: content_item.content_id, locale: locale.to_s)
    end

    reset_mongoid_query_count

    get_content content_item

    # 5 chosen as a reasonable threshold with a little headroom.
    expect(mongoid_query_count).to be <= 5
  end
end
