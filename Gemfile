source "https://rubygems.org"

gem "rails", "7.0.4"

gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk-content-schema-test-helpers"
gem "mongo", "2.15.0" # Later releases require Mongo >= 3.6
gem "mongoid"
gem "plek"
gem "rack-cache"
gem "uuidtools"
gem "whenever", require: false

group :development, :test do
  gem "ci_reporter_rspec"
  gem "climate_control"
  gem "database_cleaner-mongoid"
  gem "factory_bot"
  gem "govuk_test"

  gem "pact"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
  gem "timecop"
  gem "webmock", require: false
end

group :development do
  gem "listen"
end
