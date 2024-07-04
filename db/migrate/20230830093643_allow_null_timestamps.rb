class AllowNullTimestamps < ActiveRecord::Migration[7.0]
  def change
    change_column_null :content_items, :created_at, true # rubocop:disable Rails/BulkChangeTable
    change_column_null :content_items, :updated_at, true

    change_column_null :publish_intents, :created_at, true # rubocop:disable Rails/BulkChangeTable
    change_column_null :publish_intents, :updated_at, true

    change_column_null :scheduled_publishing_log_entries, :created_at, true # rubocop:disable Rails/BulkChangeTable
    change_column_null :scheduled_publishing_log_entries, :updated_at, true
  end
end
