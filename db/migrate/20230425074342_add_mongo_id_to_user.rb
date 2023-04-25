class AddMongoIdToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :mongo_id, :string, null: true

    add_index :users, :mongo_id
  end
end
