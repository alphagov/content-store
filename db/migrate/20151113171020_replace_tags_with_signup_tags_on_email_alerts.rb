class ReplaceTagsWithSignupTagsOnEmailAlerts < Mongoid::Migration
  def self.up
    ContentItem.any_of({base_path: /government\/policies.*email-signup.*/, rendering_app: 'email-alert-frontend'}).each do |item|
      policy = item.details["tags"]["policy"]
      item.details.delete("tags")
      item.details["signup_tags"] = { "policies" => policy }
      item.save!
    end
  end

  def self.down
    ContentItem.any_of({base_path: /government\/policies.*email-signup.*/, rendering_app: 'email-alert-frontend'}).each do |item|
      policy = item.details["signup_tags"]["policies"]
      item.details.delete("signup_tags")
      item.details["tags"] = { "policy" => policy }
      item.save!
    end
  end
end