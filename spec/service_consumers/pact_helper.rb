ENV["RAILS_ENV"] = "test"
require "webmock"
require "pact/provider/rspec"
require "rails_helper"

puts "ENV['DATABASE_URL'] = #{ENV['DATABASE_URL']}"
puts "ENV['TEST_DATABASE_URL'] = #{ENV['TEST_DATABASE_URL']}"

puts "ActiveRecord::Base.connection_db_config = #{ActiveRecord::Base.connection_db_config.inspect}"

WebMock.disable!

Pact.configure do |config|
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
end

Pact.set_up do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
end

Pact.tear_down do
  DatabaseCleaner.clean
end

def url_encode(str)
  ERB::Util.url_encode(str)
end

Pact.service_provider "Content Store" do
  honours_pact_with "Publishing API" do
    if ENV["PACT_URI"]
      pact_uri(ENV["PACT_URI"])
    else
      base_url = ENV.fetch("PACT_BROKER_BASE_URL", "https://pact-broker.cloudapps.digital")
      url = "#{base_url}/pacts/provider/#{url_encode(name)}/consumer/#{url_encode(consumer_name)}"
      version_part = "versions/#{url_encode(ENV.fetch('PACT_CONSUMER_VERSION', 'branch-deployed-to-production'))}"

      pact_uri "#{url}/#{version_part}"
    end
  end
end

Pact.provider_states_for "Publishing API" do
  set_up do
    WebMock.enable!
    WebMock.reset!
    DatabaseCleaner.clean
    User.find_or_create_by!(name: "Test user")

    escaped_router_api_prefix = Regexp.escape(Plek.find("router-api"))
    stub_request(
      :delete,
      %r{\A#{escaped_router_api_prefix}/routes},
    ).to_return(
      status: 404,
      body: "{}",
      headers: { "Content-Type" => "application/json" },
    )

    stub_request(
      :post,
      %r{\A#{escaped_router_api_prefix}/routes/commit},
    ).to_return(
      status: 200,
      body: "{}",
      headers: { "Content-Type" => "application/json" },
    )
  end

  tear_down do
    WebMock.disable!
  end

  provider_state "no content item exists with base_path /vat-rates" do
    set_up do
      # no-op
    end
  end

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
