class RemoveInfoFrontend < ActiveRecord::Migration[8.0]
  def up
    ContentItem.where(rendering_app: "info-frontend").destroy_all
  end
end
