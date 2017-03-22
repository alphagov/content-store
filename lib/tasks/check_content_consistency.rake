require "content_consistency_checker"

def report_error(base_path, errors)
  Airbrake.notify(
    "Found an inconsistent content item.",
    parameters: {
      base_path: base_path,
      errors: errors,
    }
  )

  puts "#{base_path} 😱"
  puts errors
end

def check_content(checker, base_path)
  errors = checker.check_content(base_path)
  report_error(base_path, errors) if errors.any?
end

desc "Check the items for consistency with the router-api"
task :check_content_consistency, [:routes] => [:environment] do |_, args|
  checker = ContentConsistencyChecker.new(args[:routes])
  items = ContentItem.pluck(:base_path)
  items.each do |base_path|
    check_content(checker, base_path)
  end
end
