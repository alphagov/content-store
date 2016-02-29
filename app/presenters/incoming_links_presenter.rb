class IncomingLinksPresenter
  def initialize(item, types, api_url_method)
    @item = item
    @types = types
    @api_url_method = api_url_method
  end

  def as_json(*)
    @types.each_with_object({}) do |type, hash|
      incoming_links = @item.incoming_links(type)
      hash[type] = incoming_links.map { |i| present_linked_item(i) }
    end
  end

private

  def present_linked_item(linked_item)
    LinkedItemPresenter.new(linked_item, @api_url_method).present
  end
end
