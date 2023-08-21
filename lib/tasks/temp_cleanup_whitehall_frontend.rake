desc "Removes all legacy content items that were rendered by Whitehall Frontend"
task cleanup_whitehall_frontend: :environment do
  ContentItem.where(rendering_app: "whitehall-frontend").delete_all
end
