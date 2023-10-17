class ChangeScheduledPublishingDelaySecondsToBigint < ActiveRecord::Migration[7.0]
  # we want manual control of transactions to minimise exclusive locks
  disable_ddl_transaction!

  def up
    add_column :content_items, :scheduled_publishing_delay_seconds_bigint, :bigint, null: true

    # populate temporary column in small batches, non-transactionally, to minimise locks
    done = false
    rows_updated = 0
    until done == true
      rows_updated = ContentItem.connection.update <<-SQL
        UPDATE content_items SET scheduled_publishing_delay_seconds_bigint = scheduled_publishing_delay_seconds 
        WHERE id IN (
          SELECT id FROM content_items ci2 
          WHERE ci2.scheduled_publishing_delay_seconds IS NOT NULL 
            AND ci2.scheduled_publishing_delay_seconds_bigint IS NULL
          LIMIT 5000
        );
      SQL
      remaining = ContentItem.where("scheduled_publishing_delay_seconds IS NOT NULL AND scheduled_publishing_delay_seconds_bigint IS NULL").count
      puts "#{rows_updated} rows updated, #{remaining} remaining"
      done = (remaining == 0)
    end

    ContentItem.transaction do
      rename_column :content_items, :scheduled_publishing_delay_seconds, :scheduled_publishing_delay_seconds_int
      rename_column :content_items, :scheduled_publishing_delay_seconds_bigint, :scheduled_publishing_delay_seconds
      remove_column :content_items, :scheduled_publishing_delay_seconds_int
    end
  end

  def down
    add_column :content_items, :scheduled_publishing_delay_seconds_int, :integer, null: true

    # populate temporary column in small batches, non-transactionally, to minimise locks
    done = false
    rows_updated = 0
    until done == true
      rows_updated = ContentItem.connection.update <<-SQL
        UPDATE content_items SET scheduled_publishing_delay_seconds_int = scheduled_publishing_delay_seconds 
        WHERE id IN (
          SELECT id FROM content_items ci2 
          WHERE ci2.scheduled_publishing_delay_seconds IS NOT NULL
            AND ci2.scheduled_publishing_delay_seconds_int IS NULL
          LIMIT 5000
        );
      SQL
      remaining = ContentItem.where("scheduled_publishing_delay_seconds IS NOT NULL AND scheduled_publishing_delay_seconds_int IS NULL").count
      puts "#{rows_updated} rows updated, #{remaining} remaining"
      done = (remaining == 0)
    end

    ContentItem.transaction do
      rename_column :content_items, :scheduled_publishing_delay_seconds, :scheduled_publishing_delay_seconds_bigint
      rename_column :content_items, :scheduled_publishing_delay_seconds_int, :scheduled_publishing_delay_seconds
      remove_column :content_items, :scheduled_publishing_delay_seconds_bigint
    end
  end
end
