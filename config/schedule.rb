require 'whenever'

# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_setenv is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'

set :output, {:error => 'log/cron.error.log', :standard => 'log/cron.log'}
job_type :rake, "cd :path && govuk_setenv content-store bundle exec rake :task :output"

every 1.minute do
  rake "heartbeat_messages:send"
end

every 1.day, :at => "2:00 am" do
  rake "housekeeping:cleanup_publish_intents"
end
