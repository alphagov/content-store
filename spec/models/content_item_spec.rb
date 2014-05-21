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
        stub_route_registration('/foo', 'exact', 'frontend')
        create(:content_item, :base_path => "/foo")

        @item.base_path = "/foo"
        expect(@item).not_to be_valid
        expect(@item).to have(1).error_on(:base_path)
      end

      it "should have a db level uniqueness constraint" do
        stub_route_registration('/foo', 'exact', 'frontend')
        create(:content_item, :base_path => "/foo")

        @item.base_path = "/foo"
        expect {
          @item.save! :validate => false
        }.to raise_error(Moped::Errors::OperationFailure)
      end
    end

    context 'with a route that is not below the base path' do
      before do
        @item.routes= [ { 'path' => '/wrong-path', 'type' => 'exact' } ]
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

  describe "#registerable_routes" do
    before(:each) do
      @item = build(:content_item, base_path: '/path', rendering_app: 'frontend')
    end

    it "implicitly includes the base_path as a route" do
      expected_routes = [
        RegisterableRoute.new('/path', 'exact', 'frontend')
      ]

      expect(@item.registerable_routes).to match_array(expected_routes)
    end

    it "includes explicitly set routes" do
      @item.routes = [{ 'path' => '/path.json', 'type' => 'exact' }]

      expected_routes = [
        RegisterableRoute.new('/path', 'exact', 'frontend'),
        RegisterableRoute.new('/path.json', 'exact', 'frontend')
      ]

      expect(@item.registerable_routes).to match_array(expected_routes)
    end

    it "does not duplicate the base route if already present in explicit routes" do
      @item.routes = [
        { 'path' => '/path', 'type' => 'exact' },
        { 'path' => '/path.json', 'type' => 'exact' },
        { 'path' => '/path/subpath', 'type' => 'prefix' }
      ]

      expected_routes = [
        RegisterableRoute.new('/path', 'exact', 'frontend'),
        RegisterableRoute.new('/path.json', 'exact', 'frontend'),
        RegisterableRoute.new('/path/subpath', 'prefix', 'frontend')
      ]

      expect(@item.registerable_routes).to match_array(expected_routes)
    end
  end

  context 'when saved' do
    before do
      @routes = [
        { 'path' => '/a-path', 'type' => 'exact' },
        { 'path' => '/a-path.json', 'type' => 'exact' },
        { 'path' => '/a-path/subpath', 'type' => 'prefix' }
      ]

      @routes.each do |route|
        stub_route_registration(route['path'], route['type'], 'an-app')
      end

      @item = build(:content_item, base_path: '/a-path', rendering_app: 'an-app', routes: @routes)
    end

    it 'registers the assigned routes' do
      expect_registration_of_routes(
        ['/a-path', 'exact', 'an-app'],
        ['/a-path.json', 'exact', 'an-app'],
        ['/a-path/subpath', 'prefix', 'an-app']
      )

      @item.save!
    end

    it 'saves the registered routes to the store' do
      @item.save!

      expect(@item.registered_routes).to match_array(@routes)
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
