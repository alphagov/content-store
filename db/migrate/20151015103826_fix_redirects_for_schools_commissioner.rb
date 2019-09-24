class FixRedirectsForSchoolsCommissioner < Mongoid::Migration
  def self.up
    existing_redirects = CSV.read("#{Rails.root}/db/migrate/20151015103826_fix_redirects_for_schools_commissioner.csv")

    existing_redirects.each do |from_base_path, to_base_path|
      content_item = ContentItem.find_by(base_path: from_base_path)
      content_item.update_attributes!(
        content_id: nil,
        format: "redirect",
        publishing_app: "whitehall",
        rendering_app: nil,
        redirects: [{ path: from_base_path, type: "exact", destination: to_base_path }],
        routes: [],
      )
    end
  end

  def self.down
  end
end
