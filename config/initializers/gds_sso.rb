GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = ENV.fetch("OAUTH_ID", "oauth_id")
  config.oauth_secret = ENV.fetch("OAUTH_SECRET", "secret")
  config.oauth_root_url = Plek.new.external_url_for("signon")
  config.cache = Rails.cache
  config.api_only = true
end
