namespace :report do
  desc "Run a publication delay report of the last week"
  task publication_delay_report: :environment do
    PublicationDelayReport.call($stdout)
  end

  desc "Find all references to GSI/GSE/GCSX/GSX domains"
  task find_gsi_domain_references: :environment do
    FindGsiDomainReferences.call
  end
end
