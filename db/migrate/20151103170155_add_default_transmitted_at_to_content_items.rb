class AddDefaultTransmittedAtToContentItems < Mongoid::Migration
  def self.up
    ContentItem.where(transmitted_at: nil).update_all(transmitted_at: "1")
  end
end
