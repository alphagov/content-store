class AddMongoIdToContentItems < ActiveRecord::Migration[7.0]
  def change
    add_column :content_items, :_id, :string, null: true
  end
end
