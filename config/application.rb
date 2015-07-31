require File.expand_path('../boot', __FILE__)

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
require 'statsd-ruby'

module ContentStore
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/validators)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
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

    def router_api
      @router_api ||= GdsApi::Router.new(Plek.current.find('router-api'))
    end

    def statsd
      @statsd ||= Statsd.new('localhost', 8125).tap { |s| s.namespace = 'content-store' }
    end
  end
end
