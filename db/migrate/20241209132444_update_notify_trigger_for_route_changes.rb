class UpdateNotifyTriggerForRouteChanges < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION notify_route_change() RETURNS trigger AS $$
      BEGIN
          -- Trigger on INSERT or DELETE
          IF (TG_OP = 'INSERT' OR TG_OP = 'DELETE') THEN
              PERFORM pg_notify('route_changes', '');
              RETURN COALESCE(NEW, OLD);
          END IF;

          -- Trigger on UPDATE for specific columns
          IF (TG_OP = 'UPDATE') THEN
              IF TG_TABLE_NAME = 'content_items' THEN
                -- Specific column checks for the content_items table
                IF (NEW.routes IS DISTINCT FROM OLD.routes OR
                  NEW.redirects IS DISTINCT FROM OLD.redirects OR
                  NEW.schema_name IS DISTINCT FROM OLD.schema_name OR
                  NEW.rendering_app IS DISTINCT FROM OLD.rendering_app) THEN
                  PERFORM pg_notify('route_changes', '');
                END IF;
              ELSIF TG_TABLE_NAME = 'publish_intents' THEN
                -- Specific column checks for publish_intents table
                IF (NEW.routes IS DISTINCT FROM OLD.routes OR
                    NEW.rendering_app IS DISTINCT FROM OLD.rendering_app) THEN
                    PERFORM pg_notify('route_changes', '');
                END IF;
              END IF;
          END IF;

          RETURN COALESCE(NEW, OLD);
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION notify_route_change() RETURNS trigger AS $$
      BEGIN
        PERFORM pg_notify('route_changes', '');
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end
end
