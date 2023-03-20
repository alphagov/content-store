class AddRoutesIndexesToContentItems < ActiveRecord::Migration[7.0]
  def change
    add_index :content_items, :routes, using: :gin
    add_index :content_items, :redirects, using: :gin
  end
end
