require "rails_helper"
require "pact/v2/rspec"

RSpec.describe "Verify consumers for Content Store", :pact_v2 do
  Pact::V2.configure do |config|
    config.before_provider_state_setup do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
      User.find_or_create_by!(name: "Test user")
    end

    config.after_provider_state_teardown do
      DatabaseCleaner.clean
    end
  end

  http_pact_provider "Content Store", opts: {
    http_port: 9292,
    pact_uri: ENV["PACT_URI"],
    broker_url: ENV.fetch("PACT_BROKER_BASE_URL", "https://govuk-pact-broker-6991351eca05.herokuapp.com"),
    consumer_name: "Publishing API",
    consumer_version_selectors: [
      { branch: ENV.fetch("PACT_CONSUMER_VERSION", "branch-main").delete_prefix("branch-") },
    ],
    log_level: :info,
    fail_if_no_pacts_found: true,
  }

  provider_state "a content item exists with base_path /vat-rates" do
    set_up do
      FactoryBot.create(:content_item, base_path: "/vat-rates")
    end
  end

  provider_state "a content item exists with base_path /vat-rates and payload_version 0" do
    set_up do
      FactoryBot.create(:content_item, base_path: "/vat-rates", payload_version: 0)
    end
  end

  provider_state "a content item exists with base_path /vat-rates and payload_version 10" do
    set_up do
      FactoryBot.create(:content_item, base_path: "/vat-rates", payload_version: 10)
    end
  end
end
