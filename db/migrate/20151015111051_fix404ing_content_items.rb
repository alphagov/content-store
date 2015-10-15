class Fix404ingContentItems < Mongoid::Migration
  def self.up
    existing_redirects = CSV.read("#{Rails.root}/db/migrate/20151015111051_fix404ing_content_items.csv")

    existing_redirects.each do |row|
      content_item = ContentItem.find_by(base_path: row.first)
      content_item.delete
    end
  end

  def self.down
  end
end
