# A site-facing presenter for content items, which looks up information for
# published linked items
class PublicContentItemPresenter
  PUBLIC_ATTRIBUTES = %w(base_path title description format need_ids updated_at public_updated_at details).freeze

  def initialize(item)
    @item = item
  end

  def as_json(options = nil)
    @item.as_json(options).slice(*PUBLIC_ATTRIBUTES)
  end
end
