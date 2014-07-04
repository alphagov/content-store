FactoryGirl.define do

  factory :registerable_route do
    skip_create

    path "/foo"
    type "prefix"
    rendering_app  "frontend"
  end

  factory :registerable_route_set do
    skip_create

    base_path "/foo"
    rendering_app "frontend"
    registerable_routes { [build(:registerable_route, :path => base_path, :rendering_app => rendering_app)] }
  end
end

