ENV["RAILS_ENV"]="test"
require "webmock"
require "pact/provider/rspec"

WebMock.disable!

Pact.configure do | config |
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
end

Pact.service_provider "Content Store" do
  honours_pact_with "Publishing API" do
    pact_uri ENV.fetch("PUBLISHING_API_PACT_PATH", "../publishing-api/spec/pacts/publishing_api-content_store.json")
  end
end

Pact.provider_states_for "Publishing API" do
  set_up do
    WebMock.enable!
    WebMock.reset!
  end

  tear_down do
    WebMock.disable!
  end

  provider_state "some context" do
    set_up do
      DatabaseCleaner.clean_with :truncation

      # some setup
    end
  end
end
