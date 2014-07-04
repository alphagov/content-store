require 'spec_helper'

describe RegisterableRouteSet do
  describe '.from_content_item' do
    before do
      item = build(:content_item,
                   :base_path => "/path",
                   :rendering_app => "frontend",
                   :routes => [
                     { 'path' => '/path', 'type' => 'exact'},
                     { 'path' => '/path.json', 'type' => 'exact'},
                     { 'path' => '/path/subpath', 'type' => 'prefix'},
                   ])
      @route_set = RegisterableRouteSet.from_content_item(item)
    end

    it "constructs a set of RegisterableRoutes from the item's routes" do
      expected_routes = [
        RegisterableRoute.new(:path => '/path',         :type => 'exact',  :rendering_app => 'frontend'),
        RegisterableRoute.new(:path => '/path.json',    :type => 'exact',  :rendering_app => 'frontend'),
        RegisterableRoute.new(:path => '/path/subpath', :type => 'prefix', :rendering_app => 'frontend')
      ]

      expect(@route_set.registerable_routes).to match_array(expected_routes)
    end
  end

  it 'is valid with an "exact" route matching the base_path' do
    routes    = [ build(:registerable_route, :path => '/base_path', :type => "exact") ]
    route_set = RegisterableRouteSet.new(:registerable_routes => routes, :base_path => '/base_path', :rendering_app => 'frontend')
    expect(route_set).to be_valid
  end

  it 'is valid with a "prefix" route matching the base_path' do
    routes    = [ build(:registerable_route, :path => '/base_path', :type => "prefix") ]
    route_set = RegisterableRouteSet.new(:registerable_routes => routes, :base_path => '/base_path', :rendering_app => 'frontend')
    expect(route_set).to be_valid
  end

  it 'is valid with a valid set of registerable routes' do
    routes = [
      RegisterableRoute.new(:path => '/path', :type => 'exact',  :rendering_app => 'frontend'),
      RegisterableRoute.new(:path => '/path.json', :type => 'exact',  :rendering_app => 'frontend'),
      RegisterableRoute.new(:path => '/path/exact-subpath', :type => 'exact', :rendering_app => 'frontend'),
      RegisterableRoute.new(:path => '/path/sub/path-prefix', :type => 'prefix', :rendering_app => 'frontend'),
    ]
    route_set = RegisterableRouteSet.new(:registerable_routes => routes, :base_path => '/path', :rendering_app => 'frontend')

    expect(route_set).to be_valid
  end

  it 'is invalid when a registerable route is not a valid "type"' do
    routes = [build(:registerable_route, :path => '/path', :type => 'invalid')]
    route_set = RegisterableRouteSet.new(:registerable_routes => routes, :base_path => '/path', :rendering_app => 'frontend')

    expect(route_set).to_not be_valid
  end

  it 'is invalid when there are no routes' do
    expect(RegisterableRouteSet.new(:registerable_routes => [], :base_path => '/path', :rendering_app => 'frontend')).to_not be_valid
  end

  it 'is invalid when there is no route matching the base path' do
    routes = [build(:registerable_route, :path => '/base_path')]
    route_set = RegisterableRouteSet.new(:registerable_routes => routes, :base_path => '/another-base-path', :rendering_app => 'frontend')

    expect(route_set).to_not be_valid
  end

  it 'is invalid with routes that are not beneath the base_path' do
    routes = [
      build(:registerable_route, :path => "/path"),
      build(:registerable_route, :path => "/another/sub/path"),
    ]
    route_set = RegisterableRouteSet.new(:registerable_routes => routes, :base_path => '/path', :rendering_app => 'frontend')

    expect(route_set).to_not be_valid
  end

  it 'is invalid with routes that are a string-prefix of the base_path but not an actual subpath' do
    routes = [
      build(:registerable_route, :path => "/path"),
      build(:registerable_route, :path => "/path-prefix"),
    ]
    route_set = RegisterableRouteSet.new(:registerable_routes => routes, :base_path => '/path', :rendering_app => 'frontend')

    expect(route_set).to_not be_valid
  end

  describe '#register!' do
    before do
      @routes = [
        build(:registerable_route, :path => '/path', :type => 'exact', :rendering_app => 'frontend'),
        build(:registerable_route, :path => '/path/sub/path', :type => 'prefix', :rendering_app => 'frontend'),
      ]
      @route_set = RegisterableRouteSet.new(:registerable_routes => @routes, :base_path => '/path', :rendering_app => 'frontend')
      @route_set.register!
    end

    it 'registers and commits all registeragble routes' do
      assert_routes_registered('frontend', [
        ['/path', 'exact'],
        ['/path/sub/path', 'prefix']
      ])
    end
  end
end
