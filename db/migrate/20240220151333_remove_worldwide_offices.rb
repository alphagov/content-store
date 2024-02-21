class RemoveWorldwideOffices < ActiveRecord::Migration[7.1]
  def up
    ContentItem.where(document_type: "worldwide_office").destroy_all
  end
end
