class ChangeScheduledPublishingDelaySecondsToBigint < ActiveRecord::Migration[7.0]
  def up
    change_column :content_items, :scheduled_publishing_delay_seconds, :bigint
  end

  def down
    change_column :content_items, :scheduled_publishing_delay_seconds, :integer
  end
end
