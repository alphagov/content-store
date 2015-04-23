Rails.application.routes.draw do

  with_options :format => false do |r|
    r.with_options :constraints => {:base_path => %r[/.*]} do |path_routes|
      # The /api/content route is used for requests via the public API
      path_routes.get "/api/content*base_path" => "content_items#show", :as => :content_item_api, :public_api_request => true

      path_routes.get "/content*base_path" => "content_items#show", :as => :content_item
      path_routes.put "/content*base_path" => "content_items#update"

      path_routes.get "/publish-intent*base_path" => "publish_intents#show"
      path_routes.put "/publish-intent*base_path" => "publish_intents#update"
      path_routes.delete "/publish-intent*base_path" => "publish_intents#destroy"
    end

    r.get "/healthcheck", :to => proc { [200, {}, ["OK"]] }
  end
end
