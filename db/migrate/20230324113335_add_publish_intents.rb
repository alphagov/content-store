class AddPublishIntents < ActiveRecord::Migration[7.0]
  def change
    create_table :publish_intents, id: :uuid  do |t|
      t.string :base_path, unique: true, overwrite: true
      t.date   :publish_time, type: DateTime
      t.string :publishing_app
      t.string :rendering_app
      t.string :routes, array: true, default: []

      t.timestamps
    end

    add_index :publish_intents, :base_path, unique: true
    add_index :publish_intents, :publish_time
    add_index :publish_intents, :created_at
    add_index :publish_intents, :updated_at
  end
end
