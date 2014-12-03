class FixupManualSectionFormat < Mongoid::Migration
  def self.up
    ContentItem.where(:format => "manual-section").each do |item|
      item.set(:format => "manual_section")
    end
  end

  def self.down
    ContentItem.where(:format => "manual_section").each do |item|
      item.set(:format => "manual-section")
    end
  end
end
