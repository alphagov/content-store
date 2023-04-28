class AddOptimisedRoutesIndexes < ActiveRecord::Migration[7.0]
  def up
    add_index(:content_items, :routes, using: :gin, opclass: :jsonb_path_ops, name: "ix_ci_routes_jsonb_path_ops")
    add_index(:content_items, :redirects, using: :gin, opclass: :jsonb_path_ops, name: "ix_ci_redirects_jsonb_path_ops")
    add_index(:publish_intents, :routes, using: :gin, opclass: :jsonb_path_ops, name: "ix_pi_routes_jsonb_path_ops")
  end
end
