class BackfillAuthBypassIds < Mongoid::Migration
  def self.up
    # We're moving auth_bypass_ids from access_limited to a root field of it's
    # own
    ContentItem
      .where(:access_limited.nin => [{}, nil], :auth_bypass_ids.exists => false)
      .each { |ci| ci.set(auth_bypass_ids: ci.access_limited.fetch("auth_bypass_ids", [])) }
  end

  def self.down
  end
end
