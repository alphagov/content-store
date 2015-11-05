FactoryGirl.define do
  factory :registerable_route_set do
    skip_create

    base_path "/foo"
    rendering_app "frontend"

    after :build do |rs|
      if rs.is_redirect
        rs.registerable_redirects = [{
          path: rs.base_path,
          type: "prefix",
          destination: "/bar",
        }]
      else
        rs.registerable_routes = [{
          path: rs.base_path,
          type: "prefix",
        }]
      end
    end
  end
end
