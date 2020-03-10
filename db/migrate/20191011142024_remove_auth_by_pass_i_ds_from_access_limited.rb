class RemoveAuthByPassIDsFromAccessLimited < Mongoid::Migration
  def self.up
    ContentItem
      .where(:access_limited.nin => [{}, nil])
      .each { |ci| ci.unset("access_limited.auth_bypass_ids") }
  end

  def self.down; end
end
