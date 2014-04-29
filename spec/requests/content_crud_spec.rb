require 'spec_helper'

describe "managing content" do

  describe "getting a piece of content" do
    it "should return the artefact details as JSON" do
      FactoryGirl.create(:content_artefact, :base_path => "my-path")

      get "/content/my-path"

      expect(response).to be_success
      expect(JSON.parse(response.body)).to include("base_path" => "my-path")
    end

    it "should 404 for a non-existent artefact" do
      get "/content/example"
      expect(response).to be_missing
    end
  end

  describe "creating a piece of content" do
    it "should create a document" do
      put_json "/content/test", :content => {
        :title => "Title",
        :description => "Description",
        :format => "format",
        :need_ids => [12344],
        :updated_at => Time.new(2014, 1, 1, 2, 2, 2, "+00:00"),
        :details => {}
      }

      expect(response.code.to_i).to eq(201)

      expect(JSON.parse(response.body)).to eq({
        "base_path" => "test",
        "title" => "Title",
        "description" => "Description",
        "format" => "format",
        "need_ids" => [12344],
        "updated_at" => "2014-01-01T02:02:02+00:00",
        "details" => {},
      })

      artefact = ContentArtefact.where(:base_path => 'test').first
      expect(artefact).to be
      expect(artefact.title).to eq("Title")
    end

    it "should serve a 422 error for validation errors" do
      put_json "/content/bad-data", :content => {:bad => true}

      expect(response.code.to_i).to eq(422)
    end
  end
end
