ENV["RAILS_ENV"]="test"
require "webmock"
require "pact/provider/rspec"
require "rails_helper"

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

  provider_state "an in-order request was sent to the content store" do
    set_up do
      DatabaseCleaner.clean_with :truncation
      stub_request(:any, Regexp.new(Plek.find("router-api")))

      FactoryGirl.create(
        :content_item,
        content_id: "7271a331-bbdd-411e-abb9-00127b1fae86",
        base_path: "/vat-rates",
        transmitted_at: 1000000000.0000000
      )
    end
  end

  provider_state "an out-of-order request was sent to the content store" do
    set_up do
      DatabaseCleaner.clean_with :truncation
      stub_request(:any, Regexp.new(Plek.find("router-api")))

      FactoryGirl.create(
        :content_item,
        content_id: "7271a331-bbdd-411e-abb9-00127b1fae86",
        base_path: "/vat-rates",
        transmitted_at: 1000000000.0000002
      )
    end
  end

end
