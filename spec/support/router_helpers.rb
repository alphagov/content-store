module RouterHelpers

  def expect_registration_of_routes(*routes)
    routes.each do |route_params|
      Rails.application.router_api.should_receive(:add_route).with(*route_params, skip_commit: true).ordered
    end
    Rails.application.router_api.should_receive(:commit_routes).ordered
  end
end

RSpec.configuration.include RouterHelpers
