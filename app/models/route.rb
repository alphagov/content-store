class Route < ApplicationRecord
  belongs_to :content_item, optional: true
  belongs_to :publish_intent, optional: true

  validate :content_item_or_publish_intent_present

  def self.find_matching_route(path)
    sql = <<-SQL
    SELECT
      routes.*,
      content_items.rendering_app as content_item_rendering_app,
      content_items.schema_name as content_item_schema_name,
      content_items.details as content_item_details,
      publish_intents.rendering_app as  publish_intent_rendering_app
    FROM routes
    LEFT JOIN content_items ON routes.content_item_id = content_items.id
    LEFT JOIN publish_intents ON routes.publish_intent_id = publish_intents.id
    WHERE
      (routes.match_type = 'exact' AND routes.path = :path)
      OR
      (routes.match_type = 'prefix' AND :path LIKE routes.path || '%')
    ORDER BY
      CASE WHEN routes.match_type = 'exact' THEN 1 ELSE 2 END,  -- Prioritize exact matches first
      LENGTH(routes.path) DESC
    LIMIT 1
    SQL

    Route.find_by_sql([sql, { path: }]).first
  end

  def backend
    if content_item
      if content_item.gone?
        "gone"
      elsif content_item.redirect?
        "redirect"
      else
        content_item.rendering_app
      end
    elsif publish_intent
      publish_intent.rendering_app
    end
  end

private

  def content_item_or_publish_intent_present
    unless content_item.present? || publish_intent.present?
      errors.add(:base, "A route must have either a content_item or a publish_intent")
    end
  end
end
