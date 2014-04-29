if Rails.env.development? or Rails.env.test?
  require 'ci/reporter/rake/rspec'
end
