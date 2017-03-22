require "content_consistency_checker"

namespace :check_content_consistency do
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

  desc "Check items for consistency with the router-api"
  task :one, [:routes, :base_path] => [:environment] do |_, args|
    checker = ContentConsistencyChecker.new(args[:routes])
    base_path = args[:base_path]
    check_content(checker, base_path)
  end

  desc "Check all the items for consistency with the router-api"
  task :all, [:routes] => [:environment] do |_, args|
    checker = ContentConsistencyChecker.new(args[:routes])
    items = ContentItem.pluck(:base_path)
    items.each do |base_path|
      check_content(checker, base_path)
    end
  end
end
