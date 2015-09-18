namespace :data_hygiene do
  desc "See which documents don't have content IDs"
  task :inspect_content_ids => [:environment] do
    publishing_apps = ContentItem.all.distinct("publishing_app")
    publishing_apps.each do |publishing_app|
      without_content_id = ContentItem.where(content_id: nil, publishing_app: publishing_app).count
      with_content_id = ContentItem.where(publishing_app: publishing_app).count - without_content_id

      puts "#{publishing_app}: #{without_content_id} without, #{with_content_id} with"
    end
  end
end
