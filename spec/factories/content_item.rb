FactoryGirl.define do

  # Base factory not intended to be used directly.  Present to contain common
  # attributes and traits
  factory :base_content_item, :class => ContentItem do
    sequence(:base_path) {|n| "/test-content-#{n}" }
    format 'gone' # Using gone as it allows the smallest valid base
    publishing_app 'publisher'
    update_type 'minor'
    routes { [{ 'path' => base_path, 'type' => 'exact' }] }
    phase nil

    trait :with_content_id do
      content_id { SecureRandom.uuid }
    end

    trait :with_blank_title do
      title ""
    end

    factory :content_item do
      format "answer"
      title "Test content"
      rendering_app 'frontend'
      public_updated_at Time.now
    end

    factory :redirect_content_item do
      sequence(:base_path) {|n| "/test-redirect-#{n}" }
      format "redirect"
      routes []
      redirects { [{ 'path' => base_path, 'type' => 'exact', 'destination' => '/somewhere' }] }
    end

    factory :gone_content_item do
      sequence(:base_path) {|n| "/dodo-sanctuary-#{n}" }
      format "gone"
    end

    factory :access_limited_content_item do
      sequence(:base_path) {|n| "/access-limited-#{n}" }
      access_limited {
        { "users" => [ "M6GdNZggrbGiJrLjMSbKqA", "f17250b0-7540-0131-f036-005056030202"] }
      }
    end
  end
end
