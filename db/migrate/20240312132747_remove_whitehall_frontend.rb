class RemoveWhitehallFrontend < ActiveRecord::Migration[7.1]
  def up
    ContentItem.where(rendering_app: "whitehall-frontend").delete_all
  end
end
