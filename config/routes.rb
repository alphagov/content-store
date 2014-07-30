Rails.application.routes.draw do

  with_options :format => false do |r|
    r.get "/content(*base_path)" => "content_items#show", :constraints => {:base_path => %r[/.*]}
    r.put "/content(*base_path)" => "content_items#update", :constraints => {:base_path => %r[/.*]}

    r.get "/healthcheck", :to => proc { [200, {}, ["OK"]] }
  end
end
