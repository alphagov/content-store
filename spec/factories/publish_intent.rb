FactoryGirl.define do
  factory :publish_intent do
    sequence(:base_path) { |n| "/test-content-#{n}" }
    publish_time { 40.minutes.from_now }
    rendering_app "frontend"
    routes { [{ 'path' => base_path, 'type' => 'exact' }] }
  end
end
