require 'compare_links'

namespace :compare do
  desc """
  Compare expanded links with links for migration for a schema_name
  rake 'compare:links[service_manual_guide]'
  """
  task :schema_name, [:schema_name] => :environment do |_t, args|
    schema_name = args[:schema_name]
    ContentItem.where(schema_name: schema_name).each do |item|
      CompareLink.new(item).compare
    end
  end

  desc """
  Compare expanded links with links for migration for a content item
  rake 'compare:content_item[5cb79345-4832-4f75-a48e-1d0118636a7d]'
  """
  task :content_item, [:content_item] => :environment do |_t, args|
    content_item = args[:content_item]
    content_item = ContentItem.find_by(content_id: content_item)
    compare_link = CompareLink.new(content_item)
    compare_link.show
    compare_link.compare
  end
end
