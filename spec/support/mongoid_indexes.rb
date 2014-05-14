RSpec.configure do |config|
  config.before(:suite) do
    Rails::Mongoid.create_indexes
  end
end
