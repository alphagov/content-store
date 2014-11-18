require 'gds_api/test_helpers/router'

module RouterHelpers
  include GdsApi::TestHelpers::Router

  def assert_routes_registered(rendering_app, routes)
    # Note: WebMock stubs allow you to assert against already executed requests.

    be_signature = stub_router_backend_registration(rendering_app, "http://#{rendering_app}.test.gov.uk/")
    assert_requested(be_signature, times: 1)

    routes.each do |(path, type)|
      route_signature, _ = stub_route_registration(path, type, rendering_app)
      assert_requested(route_signature, times: 1)
    end
    assert_requested(stub_router_commit, times: 1)
  end

  def assert_gone_routes_registered(routes)
    # Note: WebMock stubs allow you to assert against already executed requests.

    routes.each do |(path, type)|
      route_signature, _ = stub_gone_route_registration(path, type)
      assert_requested(route_signature, times: 1)
    end
    assert_requested(stub_router_commit, times: 1)
  end

  def assert_redirect_routes_registered(redirects)
    # Note: WebMock stubs allow you to assert against already executed requests.

    redirects.each do |(path, type, destination)|
      redirect_signature, _ = stub_redirect_registration(path, type, destination, "permanent")
      assert_requested(redirect_signature, times: 1)
    end
    assert_requested(stub_router_commit, times: 1)
  end

  def refute_routes_registered(rendering_app, routes)
    be_signature = stub_router_backend_registration(rendering_app, "http://#{rendering_app}.test.gov.uk/")
    assert_not_requested(be_signature)

    routes.each do |(path, type)|
      route_signature, _ = stub_route_registration(path, type, rendering_app)
      assert_not_requested(route_signature)
    end
    assert_not_requested(stub_router_commit)
  end
end

RSpec.configure do |config|
  config.include(RouterHelpers)

  config.before(:each) do
    stub_all_router_registration
  end
end
