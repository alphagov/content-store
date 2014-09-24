FactoryGirl.define do

  factory :content_item do
    sequence(:base_path) {|n| "/test-content-#{n}" }
    format "answer"
    title "Test content"
    publishing_app 'publisher'
    rendering_app 'frontend'
    update_type 'minor'
    routes { [{ 'path' => base_path, 'type' => 'exact' }] }

    trait :with_content_id do
      content_id { SecureRandom.uuid }
    end
  end

  factory :redirect_content_item, :class => ContentItem do
    sequence(:base_path) {|n| "/test-redirect-#{n}" }
    format "redirect"
    publishing_app 'publisher'
    update_type 'minor'
    redirects { [{ 'path' => base_path, 'type' => 'exact', 'destination' => '/somewhere' }] }
  end
end
