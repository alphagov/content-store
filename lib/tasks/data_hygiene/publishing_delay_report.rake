namespace :publishing_delay_report do
  desc "Report on the delay between scheduled and actual publication times"
  task report_delays: :environment do
    DataHygiene::PublishingDelayReporter.new.report
  end
end
