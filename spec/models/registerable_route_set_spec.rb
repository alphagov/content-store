require 'rails_helper'

describe RegisterableRouteSet, type: :model do
  describe '.from_content_item' do
    it "constructs a route set from a non-redirect content item" do
      item = build(:content_item, base_path: "/path", rendering_app: "frontend")
      item.routes = [
        { 'path' => '/path', 'type' => 'exact'},
        { 'path' => '/path.json', 'type' => 'exact'},
        { 'path' => '/path/subpath', 'type' => 'prefix'},
      ]
      route_set = RegisterableRouteSet.from_content_item(item)
      expect(route_set.is_redirect).to eq(false)
      expect(route_set.is_gone).to eq(false)
      expected_routes = [
        RegisterableRoute.new(:path => '/path',         :type => 'exact'),
        RegisterableRoute.new(:path => '/path.json',    :type => 'exact'),
        RegisterableRoute.new(:path => '/path/subpath', :type => 'prefix'),
      ]
      expect(route_set.registerable_routes).to match_array(expected_routes)
      expect(route_set.registerable_redirects).to eq([])
    end

    it "constructs a route set from a redirect content item" do
      item = build(:redirect_content_item, base_path: "/path")
      item.redirects = [
        { "path" => "/path", "type" => 'exact', "destination" => "/somewhere" },
        { "path" => "/path/foo", "type" => "prefix", "destination" => "/somewhere-else" },
      ]

      route_set = RegisterableRouteSet.from_content_item(item)
      expect(route_set.is_redirect).to eq(true)
      expect(route_set.registerable_routes).to eq([])
      expected_redirects = [
        RegisterableRedirect.new(:path => "/path", :type => "exact", :destination => "/somewhere"),
        RegisterableRedirect.new(:path => "/path/foo", :type => "prefix", :destination => "/somewhere-else"),
      ]
      expect(route_set.registerable_redirects).to match_array(expected_redirects)
    end

    it "constructs a route set from a gone content item" do
      item = build(:gone_content_item, base_path: "/path")
      item.routes = [
        { 'path' => '/path', 'type' => 'exact'},
        { 'path' => '/path.json', 'type' => 'exact'},
        { 'path' => '/path/subpath', 'type' => 'prefix'},
      ]

      route_set = RegisterableRouteSet.from_content_item(item)
      expect(route_set.is_gone).to eq(true)
      expected_routes = [
        RegisterableGoneRoute.new(:path => '/path',         :type => 'exact'),
        RegisterableGoneRoute.new(:path => '/path.json',    :type => 'exact'),
        RegisterableGoneRoute.new(:path => '/path/subpath', :type => 'prefix'),
      ]
      expect(route_set.registerable_routes).to match_array(expected_routes)
      expect(route_set.registerable_redirects).to eq([])
    end
  end

  describe '.from_publish_intent' do
    context "without a corresponding content item" do
      it "constructs a route set from a publish intent" do
        intent = build(:publish_intent, base_path: "/path", rendering_app: "frontend")
        intent.routes = [
          { 'path' => '/path', 'type' => 'exact'},
          { 'path' => '/path.json', 'type' => 'exact'},
          { 'path' => '/path/subpath', 'type' => 'prefix'},
        ]
        route_set = RegisterableRouteSet.from_publish_intent(intent)
        expect(route_set.is_redirect).to be_falsey
        expect(route_set.is_gone).to be_falsey
        expect(route_set.is_supplimentary_set).to be_falsey
        expected_routes = [
          RegisterableRoute.new(:path => '/path',         :type => 'exact'),
          RegisterableRoute.new(:path => '/path.json',    :type => 'exact'),
          RegisterableRoute.new(:path => '/path/subpath', :type => 'prefix'),
        ]
        expect(route_set.registerable_routes).to match_array(expected_routes)
        expect(route_set.registerable_redirects).to eq([])
      end
    end

    context "with a corresponding content item" do
      let!(:item) {
        create(:content_item, base_path: "/path", routes: [{"path" => "/path", "type" => "exact"}])
      }

      it "constructs a supplimentary route set for the intent" do
        intent = build(:publish_intent, base_path: "/path", rendering_app: "frontend")
        intent.routes = [
          { 'path' => '/path', 'type' => 'exact'},
          { 'path' => '/path.json', 'type' => 'exact'},
          { 'path' => '/path/subpath', 'type' => 'prefix'},
        ]

        route_set = RegisterableRouteSet.from_publish_intent(intent)
        expect(route_set.is_redirect).to be_falsey
        expect(route_set.is_gone).to be_falsey
        expect(route_set.is_supplimentary_set).to be_truthy
        expected_routes = [
          RegisterableRoute.new(:path => '/path.json',    :type => 'exact'),
          RegisterableRoute.new(:path => '/path/subpath', :type => 'prefix'),
        ]
        expect(route_set.registerable_routes).to match_array(expected_routes)
        expect(route_set.registerable_redirects).to eq([])
      end

      it "contains no routes if the content item already has all the routes in the intent" do
        intent = build(:publish_intent, base_path: "/path", rendering_app: "frontend")
        intent.routes = [ { 'path' => '/path', 'type' => 'exact' } ]

        route_set = RegisterableRouteSet.from_publish_intent(intent)
        expect(route_set.is_redirect).to be_falsey
        expect(route_set.is_gone).to be_falsey
        expect(route_set.is_supplimentary_set).to be_truthy

        expect(route_set.registerable_routes).to eq([])
        expect(route_set.registerable_redirects).to eq([])
      end
    end
  end

  describe '#register!' do
    context 'for a non-redirect route set' do
      before :each do
        @route_set = RegisterableRouteSet.new(base_path: '/path', rendering_app: 'frontend')
        @route_set.registerable_routes = [
          build(:registerable_route, :path => '/path', :type => 'exact'),
          build(:registerable_route, :path => '/path/sub/path', :type => 'prefix'),
        ]
      end

      it 'registers and commits all registerable routes' do
        @route_set.register!
        assert_routes_registered('frontend', [
          ['/path', 'exact'],
          ['/path/sub/path', 'prefix']
        ])
      end

      it 'registers and commits all registerable routes and redirects' do
        @route_set.registerable_redirects = [
          build(:registerable_redirect, :path => '/path.json', :type => 'exact', :destination => '/api/content/path'),
        ]
        @route_set.register!
        assert_routes_registered('frontend', [
          ['/path', 'exact'],
          ['/path/sub/path', 'prefix']
        ])
        assert_redirect_routes_registered([['/path.json', 'exact', '/api/content/path']])
      end
    end

    it 'is a no-op with no routes or redirects' do
      expect(Rails.application.router_api).not_to receive(:add_backend)
      expect(Rails.application.router_api).not_to receive(:add_route)
      expect(Rails.application.router_api).not_to receive(:commit_routes)

      route_set = RegisterableRouteSet.new(base_path: '/path', rendering_app: 'frontend')
      route_set.register!
    end

    it 'registers and commits all registerable redirects for a redirect item' do
      redirects = [
        build(:registerable_redirect, :path => '/path', :type => 'exact', :destination => '/new-path'),
        build(:registerable_redirect, :path => '/path/sub/path', :type => 'prefix', :destination => '/somewhere-else'),
      ]
      route_set = RegisterableRouteSet.new(registerable_redirects: redirects, base_path: '/path', is_redirect: true)
      route_set.register!
      assert_redirect_routes_registered([['/path', 'exact', '/new-path'], ['/path/sub/path', 'prefix', '/somewhere-else']])
    end

    it 'registers and commits all registerable gone routes for a gone item' do
      route_set.registerable_routes = [
        build(:registerable_gone_route, :path => '/path', :type => 'exact'),
        build(:registerable_gone_route, :path => '/path/sub/path', :type => 'prefix'),
      route_set = RegisterableRouteSet.new(base_path: '/path', rendering_app: 'frontend', is_gone: true)
      ]
      route_set.register!
      assert_gone_routes_registered([['/path', 'exact'], ['/path/sub/path', 'prefix']])
    end
  end
end
