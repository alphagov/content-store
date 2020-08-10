module Tasks
  module DataHygiene
    class InconsistentRedirectFinder
      attr_reader :content_items

      def initialize(content_items)
        @content_items = content_items
      end

      def items_with_inconsistent_redirects
        content_items.select do |content_item|
          next if content_item.format == "redirect"

          begin
            route = Rails.application.router_api.get_route(content_item.base_path)
          rescue GdsApi::HTTPNotFound
            next
          end
          route && route["handler"] == "redirect"
        end
      end
    end
  end
end
