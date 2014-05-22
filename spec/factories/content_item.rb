FactoryGirl.define do

  factory :content_item do
    sequence(:base_path) {|n| "/test-content-#{n}" }
    format "answer"
    title "Test content"
    rendering_app 'frontend'
    routes { [{ 'path' => base_path, 'type' => 'exact' }] }
  end
end
