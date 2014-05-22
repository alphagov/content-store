require 'gds_api/test_helpers/router'

module RouterHelpers
  def stub_all_route_registration
    router_api_endpoint = Plek.current.find('router-api')

    stub_request(:put, "#{router_api_endpoint}/routes")
    stub_request(:post, "#{router_api_endpoint}/routes/commit")
  end

  def expect_registration_of_routes(*routes)
    routes.each do |route_params|
      Rails.application.router_api.should_receive(:add_route).with(*route_params, skip_commit: true).ordered
    end
    Rails.application.router_api.should_receive(:commit_routes).ordered
  end
end

RSpec.configure do |config|
  config.include(RouterHelpers)
  config.include(GdsApi::TestHelpers::Router)

  config.before(:each) do
    stub_all_route_registration
  end
end
