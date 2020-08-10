require "route_consistency_checker"

def report_errors(errors)
  GovukError.notify(
    "Inconsistent routes",
    level: "warning",
    extra: { errors: errors },
  )

  errors.each do |base_path, item_errors|
    puts "#{base_path} 😱"
    puts item_errors
  end
end

desc "Check the routes for consistency with the router-api"
task :check_route_consistency, %i[routes router_data] => [:environment] do |_, args|
  raise "Must pass routes.csv.gz file" unless args[:routes]
  raise "Must pass location to router-data" unless args[:router_data]

  routes = RouteDumpLoader.load(args[:routes])
  router_data = RouterDataLoader.load(args[:router_data])

  checker = RouteConsistencyChecker.new(routes, router_data)
  checker.check_content
  checker.check_routes

  errors = checker.errors
  report_errors(errors) if errors.any?
end
