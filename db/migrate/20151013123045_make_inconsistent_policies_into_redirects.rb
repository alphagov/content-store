class MakeInconsistentPoliciesIntoRedirects < Mongoid::Migration
  def self.up
    existing_redirects = CSV.read("#{Rails.root}/db/migrate/files/inconsistent_policies.csv")

    existing_redirects.each do |from_base_path, to_base_path|
      content_item = ContentItem.find_by(base_path: from_base_path)
      content_item.update!(
        content_id: SecureRandom.uuid,
        format: "redirect",
        publishing_app: "policy-publisher",
        rendering_app: nil,
        redirects: [{ path: from_base_path, type: "exact", destination: to_base_path }],
        routes: [],
      )
    end
  end

  def self.down; end
end
