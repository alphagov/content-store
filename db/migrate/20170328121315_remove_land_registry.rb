class RemoveLandRegistry < Mongoid::Migration
  def self.up
    content_items = ContentItem.where(content_id: "5fe3c59c-7631-11e4-a3cb-005056011aef")
    content_items.destroy_all
  end

  def self.down
    raise "non-reversible migration"
  end
end
