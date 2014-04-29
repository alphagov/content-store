# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :content_artefact do
    sequence(:base_path) {|n| "content-artefact-#{n}"}
    sequence(:title)     {|n| "Title number #{n}"}
    description          "Lorem ipsum"
    format               "format"
    need_ids             [1234]
    updated_at           Time.zone.now
  end
end
