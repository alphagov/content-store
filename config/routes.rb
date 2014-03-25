ContentStore::Application.routes.draw do

  get "/healthcheck", :to => proc { [200, {}, ["OK"]] }
end
