FactoryGirl.define do

  factory :publish_intent do
    sequence(:base_path) {|n| "/test-content-#{n}" }
    publish_time { 40.minutes.from_now }
  end
end
