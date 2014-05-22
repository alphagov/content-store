require 'spec_helper'

describe RegisterableRouteSet do
  describe '.from_route_attributes' do
    before do
      routing_attributes = [
        { 'path' => '/path', 'type' => 'exact'},
        { 'path' => '/path.json', 'type' => 'exact'},
        { 'path' => '/path/subpath', 'type' => 'prefix'},
      ]
      @route_set = RegisterableRouteSet.from_route_attributes(routing_attributes, '/path', 'frontend')
    end

    it 'constructs a set of RegisterableRoutes from a routes array' do
      expected_routes = [
        RegisterableRoute.new('/path',         'exact',  'frontend'),
        RegisterableRoute.new('/path.json',    'exact',  'frontend'),
        RegisterableRoute.new('/path/subpath', 'prefix', 'frontend')
      ]

      expect(@route_set.registerable_routes).to match_array(expected_routes)
    end
  end

  it 'is valid with an "exact" route matching the base_path' do
    routes    = [ RegisterableRoute.new('/base_path', 'exact', 'frontend') ]
    route_set = RegisterableRouteSet.new(routes, '/base_path', 'frontend')
    expect(route_set).to be_valid
  end

  it 'is valid with a "prefix" route matching the base_path' do
    routes    = [ RegisterableRoute.new('/base_path', 'prefix', 'frontend') ]
    route_set = RegisterableRouteSet.new(routes, '/base_path', 'frontend')
    expect(route_set).to be_valid
  end

  it 'is valid with a valid set of registerable routes' do
    routes = [
      RegisterableRoute.new('/path', 'exact', 'frontend'),
      RegisterableRoute.new('/path.json', 'exact', 'frontend'),
      RegisterableRoute.new('/path/exact-subpath', 'exact', 'frontend'),
      RegisterableRoute.new('/path/sub/path-prefix', 'prefix', 'frontend')
    ]
    route_set = RegisterableRouteSet.new(routes, '/path', 'frontend')

    expect(route_set).to be_valid
  end

  it 'is invalid when a registerable route is not a valid "type"' do
    routes = [RegisterableRoute.new('/path', 'invalid', 'frontend')]
    route_set = RegisterableRouteSet.new(routes, '/path', 'frontend')

    expect(route_set).to_not be_valid
  end

  it 'is invalid when there are no routes' do
    expect(RegisterableRouteSet.new([],'/path', 'frontend')).to_not be_valid
  end

  it 'is invalid when there is no route matching the base path' do
    routes = [RegisterableRoute.new('/base_path', 'exact', 'frontend')]
    route_set = RegisterableRouteSet.new(routes, '/another-base-path', 'frontend')

    expect(route_set).to_not be_valid
  end

  it 'is invalid with routes that are not beneath the base_path' do
    routes = [
      RegisterableRoute.new('/path', 'exact', 'frontend'),
      RegisterableRoute.new('/another/sub/path', 'prefix', 'frontend')
    ]
    route_set = RegisterableRouteSet.new(routes, '/path', 'frontend')

    expect(route_set).to_not be_valid
  end

  it 'is invalid with routes that are a string-prefix of the base_path but not an actual subpath' do
    routes = [
      RegisterableRoute.new('/path', 'exact', 'frontend'),
      RegisterableRoute.new('/path-prefix', 'prefix', 'frontend')
    ]
    route_set = RegisterableRouteSet.new(routes, '/path', 'frontend')

    expect(route_set).to_not be_valid
  end

  describe '#register!' do
    before do
      @routes = [
        RegisterableRoute.new('/path', 'exact', 'frontend'),
        RegisterableRoute.new('/path/sub/path', 'prefix', 'frontend')
      ]
      @route_set = RegisterableRouteSet.new(@routes, '/path', 'frontend')
    end

    it 'registers and commits all registeragble routes' do
      expect_registration_of_routes(['/path', 'exact', 'frontend'], ['/path/sub/path', 'prefix', 'frontend'])

      @route_set.register!
    end
  end
end
