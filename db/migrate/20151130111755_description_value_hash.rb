class DescriptionValueHash < Mongoid::Migration
  def self.up
    puts "Migrating description strings into value hashes, e.g."
    puts "'some description' : { 'value' => 'some description' }"

    ContentItem.all.each.with_index do |item, index|
      print "." if (index % 100).zero?

      description = item["description"]

      unless description.is_a?(Hash)
        item.description = description
        item.save!(validate: false)
      end
    end

    puts
  end
end
