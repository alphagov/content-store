require_relative 'boot'

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_view/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'plek'
require 'gds_api/router'

module ContentStore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.eager_load_paths << "#{config.root}/lib"

    config.i18n.enforce_available_locales = true
    config.i18n.available_locales = [
      :en, :ar, :az, :be, :bg, :bn, :cs, :cy, :de, :dr, :el, :es, :'es-419',
      :et, :fa, :fr, :he, :hi, :hu, :hy, :id, :it, :ja, :ka, :ko, :lt,
      :lv, :ms, :pl, :ps, :pt, :ro, :ru, :si, :sk, :so, :sq, :sr, :sw, :ta, :th,
      :tk, :tr, :uk, :ur, :uz, :vi, :zh, :'zh-hk', :'zh-tw'
    ]

    # Caching defaults
    config.default_ttl = ENV.fetch('DEFAULT_TTL', 30.minutes).to_i.seconds
    config.minimum_ttl = [config.default_ttl, 5.seconds].min

    config.paths["log"] = ENV["LOG_PATH"] if ENV["LOG_PATH"]

    config.register_router_retries = 3

    def router_api
      @router_api ||= GdsApi::Router.new(
        Plek.current.find('router-api'),
        bearer_token: ENV['ROUTER_API_BEARER_TOKEN'] || 'example'
      )
    end
  end
end
