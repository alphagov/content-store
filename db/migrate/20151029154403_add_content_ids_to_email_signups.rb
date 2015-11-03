class AddContentIdsToEmailSignups < Mongoid::Migration
  def self.up
    ContentItem.any_of({base_path: /government\/policies\/.*email-signup$/}).each do |content_item|
      policy_slug = content_item.details["tags"]["policy"].first
      policy_content_id = ContentItem.any_of(
        {base_path: "/government/policies/#{policy_slug}"}
      ).first.content_id
      content_item.links[:parent] = [policy_content_id]
      content_item.save!
    end
  end

  def self.down
    # noop
  end
end

