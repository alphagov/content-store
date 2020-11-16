FactoryBot.define do
  factory :user do
    uid { SecureRandom.uuid }
  end
end
