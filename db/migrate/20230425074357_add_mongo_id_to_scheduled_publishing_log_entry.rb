class AddMongoIdToScheduledPublishingLogEntry < ActiveRecord::Migration[7.0]
  def change
    add_column :scheduled_publishing_log_entries, :mongo_id, :string, null: true
  
    add_index :scheduled_publishing_log_entries, :mongo_id
  end
end
