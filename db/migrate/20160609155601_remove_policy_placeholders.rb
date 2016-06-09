class RemovePolicyPlaceholders < Mongoid::Migration
  def self.up
    ids_to_delete = %w(12a4eb7a-6037-4cc0-aa58-0a4f2fbc5e7f e0deb0ec-e9fc-4308-b8c0-eba4dc92aa83 f656d065-43aa-4ab0-91f7-a6809ce5b68b)
    ids_to_delete.each do |id|
      ContentItem.find_by(content_id: id).destroy
    end
  end
end
