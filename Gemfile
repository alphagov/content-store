source "https://rubygems.org"

gem "gds-api-adapters", "~> 67.0.0"
gem "gds-sso", "~> 14"
gem "govuk-content-schema-test-helpers", "~> 1.6"
gem "govuk_app_config", "~> 2.2"
gem "mongo", "2.4.3"
gem "mongoid", "6.2.1"
gem "mongoid_rails_migrations", git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"
gem "plek", "~> 3.0"
gem "rails", "5.2.4.3"
gem "uuidtools", "2.1.5"
gem "whenever", "~> 1.0.0", require: false

group :development, :test do
  gem "climate_control", "~> 0.2"
  gem "database_cleaner", "~> 1.8.5"
  gem "factory_bot", "~> 5.2"
  gem "rspec-rails", "~> 4.0"
  gem "timecop", "0.9.1"
  gem "webmock", "3.8.3", require: false

  gem "ci_reporter_rspec", "~> 1.0.0"
  gem "simplecov", "0.18.5", require: false
  gem "simplecov-rcov", "0.2.3", require: false

  gem "pact"
  gem "pry-byebug"
  gem "rubocop-govuk"
end
