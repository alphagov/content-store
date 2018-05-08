namespace :report do
  desc "Run a publication delay report of the last week"
  task publication_delay_report: :environment do
    PublicationDelayReport.call($stdout)
  end
end
