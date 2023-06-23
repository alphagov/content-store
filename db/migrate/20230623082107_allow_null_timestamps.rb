class AllowNullTimestamps < ActiveRecord::Migration[7.0]
  def change
    change_column_null :content_items, :created_at, true
    change_column_null :content_items, :updated_at, true
  end
end
