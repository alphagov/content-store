class AddRoutesIndexToPublishIntents < ActiveRecord::Migration[7.0]
  def change
    add_index :publish_intents, :routes, using: :gin
  end
end
