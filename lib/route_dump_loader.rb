module RouteDumpLoader
  Route = Struct.new(:incoming_path,
                     :handler,
                     :backend_id,
                     :disabled,
                     :redirect_to,
                     :updated_at)

  def self.load(filename)
    Zlib::GzipReader.open(filename) do |file|
      csv = CSV.new(file)
      keys = csv.gets
      csv.each_with_object({}) do |row, hash|
        route_hash = Hash[keys.zip(row)].symbolize_keys
        route = Route.new(*route_hash.values_at(*Route.members))
        route.disabled = route.disabled == "true"
        route.updated_at = Time.zone.parse(route.updated_at)
        hash[route.incoming_path.to_sym] = route
      end
    end
  end
end
