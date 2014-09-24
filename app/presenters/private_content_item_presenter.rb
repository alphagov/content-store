# A tool-facing presenter for content items, which includes an update type and
# information about validation errors
class PrivateContentItemPresenter

  def initialize(item)
    @item = item
  end

  def as_json(options = nil)
    @item.as_json(options).tap do |hash|
      hash["update_type"] = @item.update_type if @item.update_type
      hash["errors"] = @item.errors.as_json.stringify_keys if @item.errors.any?
    end
  end
end
