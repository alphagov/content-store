require_relative "boot"

require "rails"
# Pick the frameworks you want:
# require "active_model/railtie"
# require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "plek"
require "gds_api/router"

module ContentStore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.enforce_available_locales = true
    config.i18n.available_locales = %i[
      ar
      az
      be
      bg
      bn
      cs
      cy
      da
      de
      dr
      el
      en
      es
      es-419
      et
      fa
      fi
      fr
      gd
      gu
      he
      hi
      hr
      hu
      hy
      id
      is
      it
      ja
      ka
      kk
      ko
      lt
      lv
      ms
      mt
      ne
      nl
      no
      pa
      pa-pk
      pl
      ps
      pt
      ro
      ru
      si
      sk
      sl
      so
      sq
      sr
      sv
      sw
      ta
      th
      tk
      tr
      uk
      ur
      uz
      vi
      yi
      zh
      zh-hk
      zh-tw
    ]

    # Caching defaults
    config.default_ttl = ENV.fetch("DEFAULT_TTL", 5.minutes).to_i.seconds
    config.minimum_ttl = [config.default_ttl, 5.seconds].min

    config.paths["log"] = ENV["LOG_PATH"] if ENV["LOG_PATH"]

    config.register_router_retries = 3

    def router_api
      @router_api ||= GdsApi::Router.new(
        Plek.current.find("router-api"),
        bearer_token: ENV["ROUTER_API_BEARER_TOKEN"] || "example",
      )
    end
  end
end
