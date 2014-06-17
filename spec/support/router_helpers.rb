require 'gds_api/test_helpers/router'

module RouterHelpers
  def assert_routes_registered(rendering_app, routes)
    # Note: WebMock stubs allow you to assert against already executed requests.


    routes.each do |(path, type)|
      route_signature, _ = stub_route_registration(path, type, rendering_app)
      assert_requested(route_signature, times: 1)
    end
    assert_requested(stub_router_commit, times: 1)
  end
end

RSpec.configure do |config|
  config.include(RouterHelpers)
  config.include(GdsApi::TestHelpers::Router)

  config.before(:each) do
    stub_all_router_registration
  end
end
