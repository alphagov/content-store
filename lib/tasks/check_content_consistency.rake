require "content_consistency_checker"

def report_errors(errors)
  Airbrake.notify(
    "Found inconsistent content items.",
    parameters: {
      errors: errors,
    }
  )

  errors.each do |base_path, item_errors|
    puts "#{base_path} 😱"
    puts item_errors
  end
end

desc "Check the items for consistency with the router-api"
task :check_content_consistency, [:routes] => [:environment] do |_, args|
  checker = ContentConsistencyChecker.new(args[:routes])
  checker.check_content

  errors = checker.errors
  report_errors(errors) if errors.any?
end
