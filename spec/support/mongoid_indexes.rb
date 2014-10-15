RSpec.configure do |config|
  config.before(:suite) do
    silence_stream(STDOUT) do
      ::Mongoid::Tasks::Database.create_indexes
    end
  end
end
