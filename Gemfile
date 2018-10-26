source 'https://rubygems.org'

gem 'rails', '5.2.1'

gem 'mongo', '2.4.3'
gem 'mongoid', '6.2.1'
gem "mongoid_rails_migrations", git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"

gem 'hashdiff', require: false
gem 'uuidtools', '2.1.5'
gem 'whenever', '~> 0.10.0', require: false

if ENV['GDS_API_ADAPTERS_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', "~> 53.2.0"
end

gem 'govuk-content-schema-test-helpers', '~> 1.6'
gem 'govuk_app_config', '~> 1.10'
gem 'plek', '~> 2.1'

group :development, :test do
  gem 'database_cleaner', '~> 1.7.0'
  gem 'factory_bot', '~> 4.11'
  gem 'rspec-rails', '~> 3.8'
  gem 'timecop', '0.9.1'
  gem 'webmock', '3.4.2', require: false

  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'simplecov', '0.16.1', require: false
  gem 'simplecov-rcov', '0.2.3', require: false

  gem "pact"
  gem "pry-byebug"

  gem "govuk-lint"
end
