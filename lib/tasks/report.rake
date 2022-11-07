namespace :report do
  desc "Run a publication delay report of the last week"
  task publication_delay_report: :environment do
    PublicationDelayReport.call($stdout)
  end

  desc "Find all references to search term"
  task :find_specific_term_references, %i[term] => [:environment] do |_, args|
    FindSpecificTerm.call(args[:term])
  end

  desc "Find all references to search term excluding document types"
  task :find_specific_term_references_excluding_types, %i[term exclude_types] => [:environment] do |_, args|
    raise "Missing excluded document types parameter" unless args[:exclude_types]

    exclude_types = args[:exclude_types].split(" ")
    FindSpecificTerm.call(args[:term], exclude_types)
  end
end
