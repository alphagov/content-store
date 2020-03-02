FactoryBot.define do
  factory :scheduled_publishing_log_entry, class: ScheduledPublishingLogEntry do
    scheduled_publication_time { Time.zone.local(2018, 1, 1) }
  end
end
