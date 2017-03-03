class ContentItem::BasePathForPath
  attr_reader :path

  def self.call(path)
    new(path).base_path
  end

  def initialize(path)
    @path = path
  end

  def base_path
    matches = find_matching_content_items(path)
    matches.present? ? best_match(matches, path) : nil
  end

private

  def find_matching_content_items(path)
    ContentItem
      .or(base_path: path)
      .or(routes: { "$elemMatch" => { path: path, type: "exact" } })
      .or(routes: { "$elemMatch" => { :path.in => potential_prefixes(path), type: "prefix" } })
      .pluck(:base_path, :routes)
  end

  def potential_prefixes(path)
    paths = path.split("/").reject(&:empty?)
    (0...paths.size).map { |i| "/#{paths[0..i].join('/')}" }
  end

  def best_match(matches, path)
    base_path_match(matches, path) ||
      exact_route_match(matches, path) ||
      best_prefix_match(matches, path)
  end

  def base_path_match(matches, path)
    path if matches.any? { |(base_path, _)| base_path == path }
  end

  def exact_route_match(matches, path)
    match = matches.find do |(_, routes)|
      routes.any? { |route| route["path"] == path && route["type"] == "exact" }
    end
    match ? match[0] : nil
  end

  def best_prefix_match(matches, path)
    prefixes = potential_prefixes(path)
    sorted = matches.sort_by do |(_, routes)|
      best_match = routes
        .select { |route| route["type"] == "prefix" && prefixes.include?(route["path"]) }
        .sort_by { |route| -route["path"].length }
        .first

      -best_match["path"].length
    end
    sorted.first.try(:first)
  end
end
