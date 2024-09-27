FactoryBot.define do
  factory :route do
    sequence(:path) { |n| "/test-#{n}" }
    match_type { "exact" }
    segments_mode { "ignore" }
    association :content_item, rendering_app: "collections"

    trait :redirect do
      association :content_item, factory: :redirect_content_item
      destination { "https://example.com" }
    end

    trait :gone do
      association :content_item, factory: :gone_content_item
    end

    trait :publish_intent do
      association :publish_intent
      content_item { nil }
    end
  end
end
