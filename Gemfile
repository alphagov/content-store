source 'https://rubygems.org'

gem 'rails', '5.0.0.1'

gem 'mongoid', '6.0.0'
gem 'mongoid_rails_migrations', '1.0.1'

gem 'logstasher', '0.5.0'
gem 'airbrake', '~> 4.3.8'

gem 'unicorn', '4.8.2'

gem 'plek', '~> 1.9'

gem 'statsd-ruby', '~> 1.2.1'

gem 'whenever', '~> 0.9.4', require: false
gem 'hashdiff', require: false

if ENV['GDS_API_ADAPTERS_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '36.0.1'
end

gem 'govuk-content-schema-test-helpers', '1.3.0'
gem 'uuidtools', '2.1.5'

group :development, :test do
  gem 'rspec-rails', '~> 3.0.2'
  gem 'database_cleaner', '~> 1.5.3'
  gem 'factory_girl', '~> 4.4.0'
  gem 'webmock', '2.1.0', require: false
  gem 'timecop', '0.7.1'

  gem 'simplecov', '0.8.2', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '~> 1.0.0'

  gem "pry-byebug"
  gem "pact"

  gem "govuk-lint"
end
