FactoryBot.define do
  factory :route do
    sequence(:path) { |n| "/test-#{n}" }
    match_type { "exact" }
  end
end
