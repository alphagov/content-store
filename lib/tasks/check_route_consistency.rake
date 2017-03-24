require "route_consistency_checker"

def report_errors(errors)
  Airbrake.notify(
    "Inconsistent routes",
    parameters: {
      errors: errors,
    }
  )

  errors.each do |base_path, item_errors|
    puts "#{base_path} 😱"
    puts item_errors
  end
end

desc "Check the routes for consistency with the router-api"
task :check_route_consistency, [:routes, :router_data] => [:environment] do |_, args|
  raise "Must pass routes.csv.gz file" unless args[:routes]
  raise "Must pass location to router-data" unless args[:router_data]

  checker = RouteConsistencyChecker.new(args[:routes], args[:router_data])
  checker.check_content
  checker.check_routes

  errors = checker.errors
  report_errors(errors) if errors.any?
end
