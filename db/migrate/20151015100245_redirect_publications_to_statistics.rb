class RedirectPublicationsToStatistics < Mongoid::Migration
  def self.up
    existing_redirects = CSV.read("#{Rails.root}/db/migrate/20151015100245_redirect_publications_to_statistics.csv")

    existing_redirects.each do |from_base_path, to_base_path|
      content_item = ContentItem.find_by(base_path: from_base_path)
      content_item.update!(
        content_id: nil,
        format: "redirect",
        publishing_app: "whitehall",
        rendering_app: nil,
        redirects: [{ path: from_base_path, type: "exact", destination: to_base_path }],
        routes: [],
      )
    end
  rescue Mongoid::Errors::DocumentNotFound
  end

  def self.down; end
end
