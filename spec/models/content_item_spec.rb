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
        item = create(:content_item, :base_path => "/foo")

        @item.base_path = "/foo"
        expect {
          @item.save! :validate => false
        }.to raise_error(Moped::Errors::OperationFailure)
      end
    end

    context 'with a route that is not below the base path' do
      before do
        @item.routes= [
          { 'path' => @item.base_path, 'type' => 'exact' },
          { 'path' => '/wrong-path', 'type' => 'exact' },
        ]
      end

      it 'should be invalid' do
        expect(@item).to_not be_valid
        expect(@item).to have(1).error_on(:routes)
      end
    end

    context 'with an invalid type of route' do
      before do
        @item.routes= [ { 'path' => @item.base_path, 'type' => 'unsupported' } ]
      end

      it 'should be invalid' do
        expect(@item).to_not be_valid
        expect(@item).to have(1).error_on(:routes)
      end
    end
  end

  context 'when saved' do
    before do
      @routes = [
        { 'path' => '/a-path', 'type' => 'exact' },
        { 'path' => '/a-path.json', 'type' => 'exact' },
        { 'path' => '/a-path/subpath', 'type' => 'prefix' }
      ]

      @item = create(:content_item, base_path: '/a-path', rendering_app: 'an-app', routes: @routes)
    end

    it 'registers the assigned routes' do
      assert_routes_registered([
        ['/a-path', 'exact', 'an-app'],
        ['/a-path.json', 'exact', 'an-app'],
        ['/a-path/subpath', 'prefix', 'an-app']
      ])
    end

    it 'saves the registered routes to the store' do
      expect(@item.registered_routes).to match_array(@routes)
    end
  end

  context 'when loaded from the content store' do
    before do
      create(:content_item, base_path: '/base_path', routes: [{ 'path' => '/base_path', 'type' => 'exact' }])
      @item = ContentItem.last
    end

    it "should be valid" do
      expect(@item).to be_valid
    end

    it 'it shoud initialise the registered routes' do
      assert_equal [RegisterableRoute.new('/base_path', 'exact', @item.rendering_app)], @item.registerable_routes
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
