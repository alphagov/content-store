# Presenter for generating the private representation of content items as seen
# by publishing tools. includes errors and update_type where applicable.
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
