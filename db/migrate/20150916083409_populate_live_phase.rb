class PopulateLivePhase < Mongoid::Migration
  def self.up
    ContentItem.where(:phase.exists => false).update_all(phase: "live")
  end

  def self.down; end
end
