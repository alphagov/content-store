class ExpandedLinksPresenter
  attr_reader :expanded_links

  def initialize(expanded_links)
    @expanded_links = expanded_links
  end

  def present
    expanded_links.each_with_object({}) do |(type, links), memo|
      links = Array.wrap(links)
      memo[type] = links.map do |link|
        link.dup.merge(
          api_path: api_path(link),
          api_url: api_url(link),
          web_url: web_url(link),
          links: link[:links].present? ? self.class.new(link[:links]).present : {}
        ).compact
      end
    end
  end

private

  def api_path(link)
    return link[:api_path] if link[:api_path]
    "/api/content" + link[:base_path] if link[:base_path]
  end

  def api_url(link)
    api_path = api_path(link)
    Plek.current.website_root + api_path if api_path
  end

  def web_url(link)
    Plek.current.website_root + link[:base_path] if link[:base_path]
  end
end
