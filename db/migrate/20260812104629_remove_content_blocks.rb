class RemoveContentBlocks < ActiveRecord::Migration[8.1]
  def up
    ContentItem.where(publishing_app: "content-block-manager").destroy_all
  end
end
