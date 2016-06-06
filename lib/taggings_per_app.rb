class TaggingsPerApp
  TAGS = %w[mainstream_browse_pages topics organisations parent].freeze

  def initialize(app_name)
    @app_name = app_name
  end

  def taggings
    relevant_content_items.each_with_object({}) do |content_item, result|
      result[content_item.content_id] = content_item.links.slice(*TAGS)
    end
  end

private

  def relevant_content_items
    ContentItem.renderable_content.where(publishing_app: @app_name)
  end
end
