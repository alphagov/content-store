class AddUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string  :name
      t.string  :uid, unique: true
      t.string  :email
      t.string  :permissions, array:  true
      t.boolean :remotely_signed_out, default: false
      t.string  :organisation_slug
      t.boolean :disabled, default: false
      t.string  :organisation_content_id
    end

    add_index :users, :uid, unique: true
    add_index :users, :email
    add_index :users, :name
    add_index :users, :organisation_content_id
    add_index :users, :organisation_slug
  end
end
