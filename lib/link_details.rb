class LinkDetails
  def initialize(scope)
    @scope = scope
  end

  def report
    @report ||= build_report
  end

  def print_report
    report.each do |(key, results)|
      puts "Link Type: #{key}"
      if results[:attributes].length > 1
        puts "Multiple attribute types for same link type"
        results[:attributes].each_index do |index|
          attributes_report(
            results[:attributes][index],
            results[:content_ids][index]
          )
        end
      else
        attributes_report(results[:attributes][0], results[:content_ids][0])
      end
    end
  end

private

  def attributes_report(attributes, content_ids)
    unusual_attributes = (attributes || []) - expected_fields
    content_ids_show = content_ids ? content_ids.sample(4) : 'None'
    puts "  Unusual Attributes: #{unusual_attributes}"
    puts "  Example Content Ids: #{content_ids_show}" if unusual_attributes
  end

  def build_report
    content_item_links = @scope.each_with_object({}) do |item, memo|
      memo[item.content_id] = presented_links(item.linked_items)
    end
    # This probably should be done better without the 3 embedded loops, left in
    # while this is just a basic proof of concept
    content_item_links.each_with_object({}) do |(id, links), memo|
      links.each do |(type, type_links)|
        type_sym = type.to_sym
        memo[type_sym] ||= { attributes: [], content_ids: [] }
        type_links.each do |link|
          fields = link.keys
          index = memo[type_sym][:attributes].find_index(fields)
          if index
            memo[type_sym][:content_ids][index] << id
          else
            memo[type_sym][:attributes] << fields
            new_index = memo[type_sym][:attributes].find_index(fields)
            memo[type_sym][:content_ids][new_index] = [id]
          end
        end
      end
    end
  end

  def presented_links(links)
    links.each_with_object({}) do |(link_type, linked_items), items|
      items[link_type] = linked_items.map do |i|
        LinkedItemPresenter.new(i, api_url_method).present
      end
    end
  end

  def api_url_method
    lambda { |path| Plek.current.website_root + "/api/content/" + path }
  end

  def expected_fields
    %w(
      analytics_identifier
      api_url
      base_path
      content_id
      description
      document_type
      links
      locale
      public_updated_at
      schema_name
      title
      web_url
    )
  end
end
