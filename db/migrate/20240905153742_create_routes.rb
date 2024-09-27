class CreateRoutes < ActiveRecord::Migration[7.2]
  def change
    create_table :routes do |t|
      t.text :path, null: false
      t.text :match_type, null: false
      t.text :destination
      t.text :segments_mode
      t.references :content_item, foreign_key: true, type: :uuid, null: true
      t.references :publish_intent, foreign_key: true, type: :uuid, null: true

      t.timestamps null: true

      t.index :path
      t.index :match_type
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO routes (content_item_id, publish_intent_id, path, match_type, destination, segments_mode, created_at, updated_at)
          SELECT
              c.id,
              null,
              route->>'path',
              route->>'type',
              route->>'destination',
              CASE
                WHEN (route->>'segments_mode') IS NULL AND (route->>'type') = 'prefix' AND c.schema_name = 'redirect' THEN 'preserve'
                WHEN (route->>'segments_mode') IS NULL AND (route->>'type') != 'prefix' AND c.schema_name = 'redirect' THEN 'ignore'
                ELSE route->>'segments_mode'
              END,
              c.created_at,
              c.updated_at
          FROM
              content_items AS c,
              LATERAL jsonb_array_elements(c.routes || c.redirects) AS route
          UNION ALL
          SELECT
              null,
              p.id,
              route->>'path',
              route->>'type',
              route->>'destination',
              route->>'segments_mode',
              p.created_at,
              p.updated_at
          FROM
              publish_intents AS p,
              LATERAL jsonb_array_elements(p.routes) AS route;
        SQL
      end
    end
  end
end
