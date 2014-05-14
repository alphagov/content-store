require 'spec_helper'

describe ContentItem do
  describe "validations" do
    before :each do
      @item = build(:content_item)
    end

    context "on base_path" do
      it "should be required" do
        @item.base_path = nil
        expect(@item).not_to be_valid
        expect(@item).to have(1).error_on(:base_path)

        @item.base_path = ''
        expect(@item).not_to be_valid
        expect(@item).to have(1).error_on(:base_path)
      end

      it "should be a valid absolute URL path" do
        [
          "/",
          "/foo",
          "/foo/bar",
          "/foo-bar/baz",
          "/foo/BAR",
        ].each do |path|
          @item.base_path = path
          expect(@item).to be_valid
        end

        [
          "not a URL path",
          "http://foo.example.com/bar",
          "bar/baz",
          "/foo/bar?baz=qux",
        ].each do |path|
          @item.base_path = path
          expect(@item).not_to be_valid
          expect(@item).to have(1).error_on(:base_path)
        end
      end

      it "should reject url paths with consecutive slashes or trailing slashes" do
        [
          "/foo//bar",
          "/foo/bar///",
          "//bar/baz",
          "//",
          "/foo/bar/",
        ].each do |path|
          @item.base_path = path
          expect(@item).not_to be_valid
          expect(@item).to have(1).error_on(:base_path)
        end
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

  it "does not include internal fields in json representation" do
    item = build(:content_item)

    expect(item.as_json.keys).not_to include("_id", "updated_at", "created_at")
  end
end
