require 'spec_helper'

describe "Fetching a content item" do

  it "should return details for the requested item" do
    create(:content_item, :base_path => "/foo/bar")

    get "/content/foo/bar"

    expect(response).to be_success
    expect(response.content_type).to eq("application/json")

    data = JSON.parse(response.body)

    expect(data['base_path']).to eq('/foo/bar')
  end

  it "should 404 for a non-existent item"
end
