require 'spec_helper'

describe ContentArtefact do
  describe "validations" do
    before :each do
      @content_artefact = FactoryGirl.build(:content_artefact)
    end
  end

  describe "as_json" do
    before :each do
      @content_artefact = FactoryGirl.build(:content_artefact)
    end

    it "should not include the MongoDB _id field in its JSON representation" do
      expect(@content_artefact.as_json).not_to have_key("_id")
    end
  end
end
