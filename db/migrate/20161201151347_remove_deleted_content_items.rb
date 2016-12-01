class RemoveDeletedContentItems < Mongoid::Migration
  def self.up
    deleted_content_ids = [
      "c5e57dfc-b959-4c4f-b3df-f78d9076e7fd",
      "29a1982c-45eb-4ec2-89eb-42bc128f1c05",
      "d865026c-74ae-4b92-bd68-eba44822aa94",
      "1cd24fea-fce1-4d32-a43e-f3ee67d6e1c9",
      "4f1807be-09ad-46bf-8883-ef578ce6b6f1",
      "dace7d69-847f-4a72-bffe-206ba917db8b",
      "18026ecc-f48b-46cd-98fc-50f0ac251a70",
      "f669bcb3-127d-4fc7-a1e2-b5255e55587a",
      "37a537f3-006a-44b2-9e40-f8c8c14b7cd6",
      "54532d6a-1cb1-4815-aefa-9ab82c578a9f",
    ]
    content_items = ContentItem.where(:content_id.in => deleted_content_ids)
    content_items.destroy_all
  end

  def self.down
    raise "non-reversible migration"
  end
end
