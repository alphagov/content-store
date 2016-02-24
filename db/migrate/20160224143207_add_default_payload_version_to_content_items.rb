class AddDefaultPayloadVersionToContentItems < Mongoid::Migration
  def self.up
    ContentItem.where(payload_version: nil).update_all(payload_version: 0)
  end
end
