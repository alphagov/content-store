ContentStore::Application.routes.draw do
  with_options :format => false do |r|
    r.resources :content, :only => [:show, :update, :destroy]

    r.get "/healthcheck" => proc { [200, {}, ["OK"]] }
  end
end
