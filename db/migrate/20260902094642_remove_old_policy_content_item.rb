class RemoveOldPolicyContentItem < ActiveRecord::Migration[8.1]
  def up
    ContentItem.where(base_path: "/government/policies/schools-and-college-qualifications-and-curriculum").destroy_all
  end
end
