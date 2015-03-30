if Rails.env.development? && ENV['DRAFT'] == 'true'
  ContentStore::Application.config.log_tags = ["DRAFT"]
end
