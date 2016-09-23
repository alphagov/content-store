RSpec.configure do |config|
  config.before(:suite) do
    silence_warnings do
      ::Mongoid::Tasks::Database.create_indexes
    end
  end
end
