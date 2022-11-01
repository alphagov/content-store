FactoryBot.define do
  # Base factory not intended to be used directly.  Present to contain common
  # attributes and traits
  factory :base_content_item, class: ContentItem do
    sequence(:base_path) { |n| "/test-content-#{n}" }
    schema_name { "gone" }
    document_type { schema_name }
    publishing_app { "publisher" }
    routes { [{ "path" => base_path, "type" => "exact" }] }
    payload_version { 0 }
    first_published_at { Time.zone.now }
    publishing_request_id { "432.432523.233242" }

    trait :with_content_id do
      content_id { SecureRandom.uuid }
    end

    trait :with_blank_title do
      title { "" }
    end

    trait :with_auth_bypass_id do
      auth_bypass_ids { [SecureRandom.uuid] }
    end

    factory :content_item do
      schema_name { "answer" }
      title { "Test content" }
      rendering_app { "frontend" }
      public_updated_at { Time.zone.now }
    end

    factory :content_item_with_content_id, traits: [:with_content_id]

    factory :redirect_content_item do
      sequence(:base_path) { |n| "/test-redirect-#{n}" }
      schema_name { "redirect" }
      routes { [] }
      redirects { [{ "path" => base_path, "type" => "exact", "destination" => "/somewhere" }] }
    end

    factory :gone_content_item do
      sequence(:base_path) { |n| "/dodo-sanctuary-#{n}" }
      schema_name { "gone" }
    end

    factory :gone_content_item_with_details do
      sequence(:base_path) { |n| "/messy-language-stuff-#{n}" }
      schema_name { "gone" }
      details do
        {
          explanation: "<div class=\"govspeak\"><p>Explanation…</p> </div>",
          alternative_path: "/example",
        }
      end
    end

    factory :gone_content_time_with_empty_details_fields do
      sequence(:base_path) { |n| "/more-gone-than-the-other-gone-#{n}" }
      schema_name { "gone" }
      details do
        {
          explanation: "",
          alternative_path: "",
        }
      end
    end

    factory :access_limited_content_item, parent: :content_item do
      sequence(:base_path) { |n| "/access-limited-#{n}" }

      trait :by_user_id do
        access_limited do
          {
            "users" => %w[M6GdNZggrbGiJrLjMSbKqA f17250b0-7540-0131-f036-005056030202],
          }
        end
      end

      trait :by_org_id do
        access_limited do
          {
            "organisations" => %w[f17250b0-7540-0131-f036-005056030202],
          }
        end
      end
    end
  end
end
