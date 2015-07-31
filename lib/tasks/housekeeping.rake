namespace :housekeeping do

  desc "Delete any publish intents in the past"
  task :cleanup_publish_intents => :environment do
    PublishIntent.cleanup_expired
  end
end
