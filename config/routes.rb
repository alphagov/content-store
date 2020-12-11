Rails.application.routes.draw do
  scope format: false do
    # The /api/content route is used for requests via the public API
    get "/api/content(/*path_without_root)" => "content_items#show", :as => :content_item_api, :public_api_request => true
    get "/api/content-id/:content_id" => "content_items#show_by_id"

    get "/content(/*path_without_root)" => "content_items#show", :as => :content_item
    put "/content(/*base_path_without_root)" => "content_items#update"
    delete "/content(/*base_path_without_root)" => "content_items#destroy"

    get "/publish-intent(/*path_without_root)" => "publish_intents#show", :as => :publish_intent
    put "/publish-intent(/*base_path_without_root)" => "publish_intents#update"
    delete "/publish-intent(/*base_path_without_root)" => "publish_intents#destroy"
  end

  get "/healthcheck", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::Mongoid,
  )
end
