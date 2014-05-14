FactoryGirl.define do

  factory :content_item do
    sequence(:base_path) {|n| "/test-content-#{n}" }
    format "answer"
    title "Test content"
  end
end
