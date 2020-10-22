# 1. Turn off default simplecov filters

#   spec_helper.rb

#   require "simplecov"
#   SimpleCov.start do
#     filters.clear
#   end
#   ...

# 2. Run tests

# 3. Detect possibly unused gems

require "json"

simplecov_results = ""

File.open("./coverage/.resultset.json", "r") do |f|
  simplecov_results = JSON.parse(f.read)
end

covered_gem_keys = simplecov_results["RSpec"]["coverage"].keys.select { |k| k =~ /gem/ }

unless covered_gem_keys.count.positive?
  abort("Simple cov report shows no gems covered.")
end

# Remove start of path to gem
covered_gem_keys.map! { |k| k.gsub(/.*\/gems\//, "") }

# Remove anything following the gem name
covered_gem_keys.map! { |k| k.gsub(/\/lib.*/, "") }

covered_gem_keys.uniq! # Remove coverage hits for multiple files within a gem
covered_gem_keys.sort!

# Build a list of all bundled gem names
bundled_gems = `bundle list`.split("\n")[1..]       # Ignore first comment line
bundled_gems.map! { |g| g.gsub(/^(\*|\s)*/, "") }   # Remove whitespace and asterisk prefix
bundled_gems.map! { |g| g.gsub(/\s*\(.*\)$/, "") }  # Remove trailing whitespace and version number

rails_gems = [
  "actioncable",
  "actionmailbox",
  "actionmailer",
  "actionpack",
  "actiontext",
  "actionview",
  "activejob",
  "activemodel",
  "activerecord",
  "activestorage",
  "activesupport",
  "addressable",
  "amq-protocol",
  "ansi",
  "ast",
  "aws-eventstream",
  "aws-partitions",
  "aws-sdk-core",
  "aws-sdk-kms",
  "aws-sdk-s3",
  "aws-sdk-sns",
  "aws-sigv4",
  "azure-storage-blob",
  "azure-storage-common",
  "backburner",
  "bcrypt",
  "beaneater",
  "benchmark-ips",
  "blade",
  "blade-qunit_adapter",
  "blade-sauce_labs_plugin",
  "bootsnap",
  "builder",
  "bunny",
  "byebug",
  "capybara",
  "childprocess",
  "coffee-script",
  "coffee-script-source",
  "concurrent-ruby",
  "connection_pool",
  "cookiejar",
  "crack",
  "crass",
  "curses",
  "daemons",
  "dalli",
  "dante",
  "declarative",
  "declarative-option",
  "delayed_job",
  "delayed_job_active_record",
  "digest-crc",
  "em-http-request",
  "em-socksify",
  "erubi",
  "et-orbi",
  "event_emitter",
  "eventmachine",
  "execjs",
  "faraday",
  "faraday_middleware",
  "faye",
  "faye-websocket",
  "ffi",
  "fugit",
  "globalid",
  "google-api-client",
  "google-cloud-core",
  "google-cloud-env",
  "google-cloud-errors",
  "google-cloud-storage",
  "googleauth",
  "hashdiff",
  "hiredis",
  "http_parser.rb",
  "httpclient",
  "i18n",
  "image_processing",
  "jmespath",
  "json",
  "jwt",
  "kindlerb",
  "libxml-ruby",
  "listen",
  "loofah",
  "mail",
  "marcel",
  "memoist",
  "method_source",
  "mimemagic",
  "mini_magick",
  "mini_mime",
  "mini_portile2",
  "minitest",
  "minitest-bisect",
  "minitest-reporters",
  "minitest-retry",
  "minitest-server",
  "mono_logger",
  "msgpack",
  "multi_json",
  "multipart-post",
  "mustache",
  "mustermann",
  "mysql2",
  "nio4r",
  "nokogiri",
  "os",
  "parallel",
  "parser",
  "path_expander",
  "pg",
  "public_suffix",
  "puma",
  "que",
  "queue_classic",
  "qunit-selenium",
  "raabro",
  "racc",
  "rack",
  "rack-cache",
  "rack-protection",
  "rack-proxy",
  "rack-test",
  "rails",
  "rails-dom-testing",
  "rails-html-sanitizer",
  "railties",
  "rainbow",
  "rake",
  "rb-fsevent",
  "rb-inotify",
  "rdoc",
  "redcarpet",
  "redis",
  "redis-namespace",
  "regexp_parser",
  "representable",
  "resque",
  "resque-scheduler",
  "retriable",
  "rexml",
  "rouge",
  "rubocop",
  "rubocop-ast",
  "rubocop-packaging",
  "rubocop-performance",
  "rubocop-rails",
  "ruby-progressbar",
  "ruby-vips",
  "rubyzip",
  "rufus-scheduler",
  "safe_yaml",
  "sass-rails",
  "sassc",
  "sassc-rails",
  "sdoc",
  "selenium-webdriver",
  "semantic_range",
  "sequel",
  "serverengine",
  "sidekiq",
  "sigdump",
  "signet",
  "sinatra",
  "sneakers",
  "sprockets",
  "sprockets-export",
  "sprockets-rails",
  "sqlite3",
  "stackprof",
  "sucker_punch",
  "thin",
  "thor",
  "tilt",
  "turbolinks",
  "turbolinks-source",
  "tzinfo",
  "uber",
  "uglifier",
  "unicode-display_width",
  "useragent",
  "vegas",
  "w3c_validators",
  "webdrivers",
  "webmock",
  "webpacker",
  "websocket",
  "websocket-client-simple",
  "websocket-driver",
  "websocket-extensions",
  "xpath",
  "zeitwerk",
]

test_and_analysis_gem_partial_names = %w[
  ci
  rubocop
  simplecov
]

server_and_related_gems = %w[
  kgio
  raindrops
  unicorn
  webrick
]

other_gems_to_exclude = %w[
  bundler
  logstasher
]

possibly_unused_gems = bundled_gems.reject do |gem|
  # Don't flag gems that we know have been used by code coverage
  covered_gem_keys.any? { |gem_key| gem_key =~ /#{Regexp.quote(gem)}/ } ||
    # Don't flag gems that are included in Rails
    rails_gems.include?(gem) ||
    # Don't flag testing / code analysis / server gems
    (test_and_analysis_gem_partial_names + server_and_related_gems).any? { |gem_key| /#{Regexp.quote(gem_key)}/ =~ gem } ||
    # Don't flag other gems we know are in use
    other_gems_to_exclude.include?(gem)
end

puts "This application is bundled with #{covered_gem_keys.count + possibly_unused_gems.count} gems."
puts "Based on code coverage, it seems that at least #{covered_gem_keys.count} gems are used from your Gemfile"
puts "The following #{possibly_unused_gems.count} gems may not be used:"
puts possibly_unused_gems
