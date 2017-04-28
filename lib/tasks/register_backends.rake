desc "
  Register backends with the router-api for all rendering apps in the
  database.
"
task register_backends: :environment do
  ContentItem.distinct(:rendering_app).compact.each do |rendering_app|
    backend = "#{Plek.find(rendering_app)}/"
    puts "Adding backend #{backend} for #{rendering_app}"
    Rails.application.router_api.add_backend(rendering_app, backend)
  end
end
