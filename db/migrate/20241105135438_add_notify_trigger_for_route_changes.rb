class AddNotifyTriggerForRouteChanges < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION notify_route_change() RETURNS trigger AS $$
      BEGIN
        PERFORM pg_notify('route_changes', '');
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER content_item_change_trigger
      AFTER INSERT OR UPDATE OR DELETE ON content_items
      FOR EACH ROW EXECUTE PROCEDURE notify_route_change();
    SQL

    execute <<-SQL
      CREATE TRIGGER publish_intent_change_trigger
      AFTER INSERT OR UPDATE OR DELETE ON publish_intents
      FOR EACH ROW EXECUTE PROCEDURE notify_route_change();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS content_item_change_trigger ON content_items;
    SQL

    execute <<-SQL
      DROP TRIGGER IF EXISTS publish_intent_change_trigger ON publish_intents;
    SQL

    execute <<-SQL
      DROP FUNCTION IF EXISTS notify_route_change();
    SQL
  end
end
