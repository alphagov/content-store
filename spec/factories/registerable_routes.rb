FactoryGirl.define do

  factory :registerable_route do
    skip_create

    path "/foo"
    type "prefix"
  end

  factory :registerable_gone_route, parent: :registerable_route do
  end

  factory :registerable_redirect do
    skip_create

    path "/foo"
    type "prefix"
    destination "/bar"
  end

  factory :registerable_route_set do
    skip_create

    base_path "/foo"
    rendering_app "frontend"

    after :build do |rs|
      if rs.is_redirect
        rs.registerable_redirects = [build(:registerable_redirect, :path => rs.base_path)]
      else
        rs.registerable_routes = [build(:registerable_route, :path => rs.base_path)]
      end
    end
  end
end

