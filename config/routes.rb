Rails.application.routes.draw do
  scope format: false do
    # The /api/content route is used for requests via the public API
    get "/api/content(/*path_without_root)" => "content_items#show", :as => :content_item_api, :public_api_request => true

    get "/content(/*path_without_root)" => "content_items#show", :as => :content_item
    put "/content(/*base_path_without_root)" => "content_items#update"
    delete "/content(/*base_path_without_root)" => "content_items#destroy"

    get "/publish-intent(/*path_without_root)" => "publish_intents#show", :as => :publish_intent
    put "/publish-intent(/*base_path_without_root)" => "publish_intents#update"
    delete "/publish-intent(/*base_path_without_root)" => "publish_intents#destroy"

    get "/sleep/ruby/:wait" => "content_items#sleep_ruby"
    get "/sleep/mongo/:wait" => "content_items#sleep_mongo"
  end

  get "/healthcheck", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::Mongoid,
  )

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::Mongoid,
  )
end
