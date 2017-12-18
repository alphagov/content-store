source 'https://rubygems.org'

gem 'rails', '5.1.1'

gem 'mongoid', '6.1.0'
gem "mongoid_rails_migrations", git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"

gem 'logstasher', '0.5.0'

gem 'unicorn', '4.8.2'

gem 'plek', '~> 2.0'

gem 'statsd-ruby', '~> 1.4'

gem 'whenever', '~> 0.10.0', require: false
gem 'hashdiff', require: false

if ENV['GDS_API_ADAPTERS_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', "~> 50.0.0"
end

gem 'govuk_app_config', '~> 0.2'

gem 'govuk-content-schema-test-helpers', '~> 1.4'
gem 'uuidtools', '2.1.5'

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'database_cleaner', '~> 1.6.1'
  gem 'factory_bot', '~> 4.8'
  gem 'webmock', '2.3.2', require: false
  gem 'timecop', '0.7.1'

  gem 'simplecov', '0.8.2', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '~> 1.0.0'

  gem "pry-byebug"
  gem "pact"

  gem "govuk-lint"
end
