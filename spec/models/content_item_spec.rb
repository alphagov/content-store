require 'spec_helper'

describe ContentItem do
  describe "validations" do
    before :each do
      @item = build(:content_item)
    end

    context "#base_path" do
      it "should be required" do
        @item.base_path = nil
        expect(@item).not_to be_valid
        expect(@item).to have(1).error_on(:base_path)

        @item.base_path = ''
        expect(@item).not_to be_valid
        expect(@item).to have(1).error_on(:base_path)
      end

      it "should be an absolute path" do
        @item.base_path = '/valid/absolute/path'
        expect(@item).to be_valid

        @item.base_path = 'invalid//absolute/path/'
        expect(@item).to_not be_valid
      end

      it "should be unique" do
        create(:content_item, :base_path => "/foo")
        @item.base_path = "/foo"
        expect(@item).not_to be_valid
        expect(@item).to have(1).error_on(:base_path)
      end

      it "should have a db level uniqueness constraint" do
        create(:content_item, :base_path => "/foo")
        @item.base_path = "/foo"
        expect {
          @item.save! :validate => false
        }.to raise_error(Moped::Errors::OperationFailure)
      end
    end
  end

  describe "json representation" do
    before :each do
      @item = build(:content_item)
    end

    it "only includes public attributes" do
      expect(@item.as_json.keys).to match_array(ContentItem::PUBLIC_ATTRIBUTES)
    end

    it "outputs the base_path correctly" do
      expect(@item.as_json["base_path"]).to eq(@item.base_path)
    end

    it "includes details of any errors" do
      @item.title = ""
      @item.valid?

      json_hash = @item.as_json
      expect(json_hash).to have_key("errors")
      expect(json_hash["errors"]).to eq({"title" => ["can't be blank"]})
    end

    it "does not include the 'errors' key if there are no errors" do
      expect(@item.as_json).not_to have_key("errors")
    end
  end
end
