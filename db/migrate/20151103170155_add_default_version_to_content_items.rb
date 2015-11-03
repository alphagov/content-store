class AddDefaultVersionToContentItems < Mongoid::Migration
  def self.up
    ContentItem.where(version: nil).update_all(version: 1)
  end
end
