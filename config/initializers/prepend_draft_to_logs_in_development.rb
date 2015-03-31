if Rails.env.development? && ENV['DRAFT'].present?
  ContentStore::Application.config.log_tags = ["DRAFT"]
end
