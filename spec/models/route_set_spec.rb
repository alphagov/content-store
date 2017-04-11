require 'rails_helper'

describe RouteSet, type: :model do
  describe '.from_content_item' do
    it "constructs a route set from a non-redirect content item" do
      item = build(:content_item, base_path: "/path", rendering_app: "frontend")
      item.routes = [
        { 'path' => '/path', 'type' => 'exact' },
        { 'path' => '/path.json', 'type' => 'exact' },
        { 'path' => '/path/subpath', 'type' => 'prefix' },
      ]
      route_set = RouteSet.from_content_item(item)
      expect(route_set.is_redirect).to eq(false)
      expect(route_set.is_gone).to eq(false)
      expected_routes = [
        { path: '/path', type: 'exact' },
        { path: '/path.json', type: 'exact' },
        { path: '/path/subpath', type: 'prefix' },
      ]
      expect(route_set.routes).to match_array(expected_routes)
      expect(route_set.gone_routes).to eq([])
      expect(route_set.redirects).to eq([])
    end

    it "constructs a route set from a redirect content item" do
      item = build(:redirect_content_item, base_path: "/path")
      item.redirects = [
        { "path" => "/path", "type" => 'exact', "destination" => "/somewhere" },
        { "path" => "/path/foo", "type" => "prefix", "destination" => "/somewhere-else" },
      ]

      route_set = RouteSet.from_content_item(item)
      expect(route_set.is_redirect).to eq(true)
      expect(route_set.routes).to eq([])
      expect(route_set.gone_routes).to eq([])
      expected_redirects = [
        { path: "/path", type: "exact", destination: "/somewhere" },
        { path: "/path/foo", type: "prefix", destination: "/somewhere-else" },
      ]
      expect(route_set.redirects).to match_array(expected_redirects)
    end

    it "constructs a route set from a gone content item" do
      item = build(:gone_content_item, base_path: "/path")
      item.routes = [
        { 'path' => '/path', 'type' => 'exact' },
        { 'path' => '/path.json', 'type' => 'exact' },
        { 'path' => '/path/subpath', 'type' => 'prefix' },
      ]

      route_set = RouteSet.from_content_item(item)
      expect(route_set.is_gone).to eq(true)
      expected_routes = [
        { path: '/path', type: 'exact' },
        { path: '/path.json', type: 'exact' },
        { path: '/path/subpath', type: 'prefix' },
      ]
      expect(route_set.routes).to eq([])
      expect(route_set.gone_routes).to match_array(expected_routes)
      expect(route_set.redirects).to eq([])
    end
  end

  describe '.from_publish_intent' do
    context "without a corresponding content item" do
      it "constructs a route set from a publish intent" do
        intent = build(:publish_intent, base_path: "/path", rendering_app: "frontend")
        intent.routes = [
          { 'path' => '/path', 'type' => 'exact' },
          { 'path' => '/path.json', 'type' => 'exact' },
          { 'path' => '/path/subpath', 'type' => 'prefix' },
        ]
        route_set = RouteSet.from_publish_intent(intent)
        expect(route_set.is_redirect).to be_falsey
        expect(route_set.is_gone).to be_falsey
        expected_routes = [
          { path: '/path', type: 'exact' },
          { path: '/path.json', type: 'exact' },
          { path: '/path/subpath', type: 'prefix' },
        ]
        expect(route_set.routes).to match_array(expected_routes)
        expect(route_set.gone_routes).to eq([])
        expect(route_set.redirects).to eq([])
      end
    end

    context "with a corresponding content item" do
      let!(:item) {
        create(:content_item, base_path: "/path", routes: [{ "path" => "/path", "type" => "exact" }])
      }

      it "constructs a supplimentary route set for the intent" do
        intent = build(:publish_intent, base_path: "/path", rendering_app: "frontend")
        intent.routes = [
          { 'path' => '/path', 'type' => 'exact' },
          { 'path' => '/path.json', 'type' => 'exact' },
          { 'path' => '/path/subpath', 'type' => 'prefix' },
        ]

        route_set = RouteSet.from_publish_intent(intent)
        expect(route_set.is_redirect).to be_falsey
        expect(route_set.is_gone).to be_falsey
        expected_routes = [
          { path: '/path.json', type: 'exact' },
          { path: '/path/subpath', type: 'prefix' },
        ]
        expect(route_set.routes).to match_array(expected_routes)
        expect(route_set.gone_routes).to eq([])
        expect(route_set.redirects).to eq([])
      end

      it "contains no routes if the content item already has all the routes in the intent" do
        intent = build(:publish_intent, base_path: "/path", rendering_app: "frontend")
        intent.routes = [{ 'path' => '/path', 'type' => 'exact' }]

        route_set = RouteSet.from_publish_intent(intent)
        expect(route_set.is_redirect).to be_falsey
        expect(route_set.is_gone).to be_falsey

        expect(route_set.routes).to eq([])
        expect(route_set.gone_routes).to eq([])
        expect(route_set.redirects).to eq([])
      end
    end
  end

  describe '#register!' do
    context 'for a non-redirect route set' do
      before :each do
        @route_set = RouteSet.new(base_path: '/path', rendering_app: 'frontend')
        @route_set.routes = [
          { path: '/path', type: 'exact' },
          { path: '/path/sub/path', type: 'prefix' },
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
        @route_set.redirects = [
          { path: '/path.json', type: 'exact', destination: '/api/content/path' },
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

      route_set = RouteSet.new(base_path: '/path', rendering_app: 'frontend')
      route_set.register!
    end

    it 'registers and commits all registerable redirects for a redirect item' do
      redirects = [
        { path: '/path', type: 'exact', destination: '/new-path' },
        { path: '/path/sub/path', type: 'prefix', destination: '/somewhere-else' },
        {
          path: '/path/longer/sub/path',
          type: 'prefix',
          destination: '/somewhere-else-2',
          segments_mode: 'ignore',
        },
      ]
      route_set = RouteSet.new(redirects: redirects, base_path: '/path', is_redirect: true)
      route_set.register!
      assert_redirect_routes_registered([['/path', 'exact', '/new-path'], ['/path/sub/path', 'prefix', '/somewhere-else'], ['/path/longer/sub/path', 'prefix', '/somewhere-else-2', 'ignore']])
    end

    it 'registers and commits all registerable gone routes for a gone item' do
      route_set = RouteSet.new(base_path: '/path', rendering_app: 'frontend', is_gone: true)
      route_set.gone_routes = [
        { path: '/path', type: 'exact' },
        { path: '/path/sub/path', type: 'prefix' },
      ]
      route_set.register!
      assert_gone_routes_registered([['/path', 'exact'], ['/path/sub/path', 'prefix']])
    end
  end
end
