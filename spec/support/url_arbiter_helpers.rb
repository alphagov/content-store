require "govuk/client/test_helpers/url_arbiter"

RSpec.configure do |config|
  config.include(GOVUK::Client::TestHelpers::URLArbiter, :type => :request)

  config.before(:each, :type => :request) do
    stub_default_url_arbiter_responses
  end
end

