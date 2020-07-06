class RemoveObseleteContentItemsIndex < Mongoid::Migration
  def self.up
    collection.indexes.drop_one(key)
  rescue StandardError
    # if the collection doesn't exist, we don't care.
  end

  def self.down
    collection.indexes.create_one(key)
  end

private

  def self.key
    { content_id: 1, locale: 1, format: 1, updated_at: -1, title: 1, _id: 1 }
  end

  def self.collection
    db = connection.database
    db.collection(:content_items)
  end
end
