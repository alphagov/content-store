require 'gds_api/test_helpers/router'

module RouterHelpers
  def stub_all_route_registration
    stub_request(:put, "#{router_api_endpoint}/routes")
    stub_request(:post, "#{router_api_endpoint}/routes/commit")
  end

  def assert_routes_registered(routes, times=1)
    routes.each do |route_params|
      request_param = { route: {
          incoming_path: route_params[0],
          route_type: route_params[1],
          handler: 'backend',
          backend_id: route_params[2] }
      }
      assert_requested(:put, "#{router_api_endpoint}/routes", :body => request_param, times: times)
    end
    assert_requested(:post, "#{router_api_endpoint}/routes/commit", times: times)
  end

private

  def router_api_endpoint
    Plek.current.find('router-api')
  end
end

RSpec.configure do |config|
  config.include(RouterHelpers)
  config.include(GdsApi::TestHelpers::Router)

  config.before(:each) do
    stub_all_route_registration
  end
end
