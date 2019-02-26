namespace :report do
  desc "Run a publication delay report of the last week"
  task publication_delay_report: :environment do
    PublicationDelayReport.call($stdout)
  end

  desc "Find all references to search term"
  task task :find_specific_term_references, %i[term] => [:environment] do |_, args|
    FindSpecificTerm.call(args[:term])
  end
end
