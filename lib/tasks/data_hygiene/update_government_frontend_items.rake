namespace :data_hygiene do
  desc "Update content items still pointing to government-frontend"
  task update_government_frontend_items: [:environment] do
    items = ContentItem.where(rendering_app: "government-frontend")
    puts("Updating #{items.count} items to render via frontend")
    items.update_all(rendering_app: "frontend")
  end
end
