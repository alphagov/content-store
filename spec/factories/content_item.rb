FactoryGirl.define do
  # Base factory not intended to be used directly.  Present to contain common
  # attributes and traits
  factory :base_content_item, class: ContentItem do
    sequence(:base_path) { |n| "/test-content-#{n}" }
    format 'gone' # Using gone as it allows the smallest valid base
    schema_name { format }
    document_type { format }
    publishing_app 'publisher'
    routes { [{ 'path' => base_path, 'type' => 'exact' }] }
    payload_version 0
    first_published_at { Time.now }
    publishing_request_id { "432.432523.233242" }

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
      public_updated_at { Time.now }
    end

    factory :content_item_with_content_id, traits: [:with_content_id]

    factory :redirect_content_item do
      sequence(:base_path) { |n| "/test-redirect-#{n}" }
      format "redirect"
      routes []
      redirects { [{ 'path' => base_path, 'type' => 'exact', 'destination' => '/somewhere' }] }
    end

    factory :gone_content_item do
      sequence(:base_path) { |n| "/dodo-sanctuary-#{n}" }
      format "gone"
    end

    factory :gone_content_item_with_details do
      sequence(:base_path) { |n| "/messy-language-stuff-#{n}" }
      format "gone"
      details {
        {
          explanation: "<div class=\"govspeak\"><p>Explanation…</p> </div>",
          alternative_path: "/example"
        }
      }
    end

    factory :gone_content_time_with_empty_details_fields do
      sequence(:base_path) { |n| "/more-gone-than-the-other-gone-#{n}" }
      format "gone"
      details {
        {
          explanation: "",
          alternative_path: ""
        }
      }
    end

    factory :access_limited_content_item, parent: :content_item do
      sequence(:base_path) { |n| "/access-limited-#{n}" }

      trait :by_user_id do
        access_limited {
          {
            "users" => ["M6GdNZggrbGiJrLjMSbKqA", "f17250b0-7540-0131-f036-005056030202"],
          }
        }
      end

      trait :by_auth_bypass_id do
        access_limited {
          {
            "auth_bypass_ids" => ["85aa9fd5-c514-4964-b931-5b597e4ec668"]
          }
        }
      end
    end
  end
end
