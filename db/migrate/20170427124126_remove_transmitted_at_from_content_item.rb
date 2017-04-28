class RemoveTransmittedAtFromContentItem < Mongoid::Migration
  def self.up
    ContentItem.all.each do |content_item|
      content_item.unset(:transmitted_at)
    end
  end

  def self.down
  end
end
