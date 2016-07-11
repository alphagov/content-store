require 'link_details'

namespace :link_details do
  desc """
  Show attributes that are unusual in links for a particular document type and
  some sample content ids to find them.
  Used in the process to migrate link generation from Content Store to
  Publishing API
  rake 'link_details:document_type[service_manual_guide]'
  """
  task :document_type, [:document_type] => :environment do |_t, args|
    document_type = args[:document_type]
    scope = ContentItem.where(document_type: document_type)
    LinkDetails.new(scope).print_report
  end

  desc """
  Show attributes that are unusual in links for all document types.
  This will take a long time to run.
  Used in the process to migrate link generation from Content Store to
  Publishing API
  rake 'link_details:all'
  """
  task all: :environment do
    document_types = ContentItem.distinct(:document_type)
    (document_types - ['working_group']).each do |document_type|
      puts "\nDocument Type: #{document_type}\n"
      scope = ContentItem.where(document_type: document_type)
      LinkDetails.new(scope).print_report
    end
  end
end
