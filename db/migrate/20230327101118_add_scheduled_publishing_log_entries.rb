class AddScheduledPublishingLogEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :scheduled_publishing_log_entries, id: :uuid do |t|
      t.string    :base_path
      t.string    :document_type
      t.datetime  :scheduled_publication_time
      t.integer   :delay_in_milliseconds
    end

    add_index :scheduled_publishing_log_entries, :base_path, name: 'ix_scheduled_pub_log_base_path'
    add_index :scheduled_publishing_log_entries, :scheduled_publication_time, name: 'ix_scheduled_pub_log_time'
  end
end
