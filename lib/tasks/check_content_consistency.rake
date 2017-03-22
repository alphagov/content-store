require "content_consistency_checker"

namespace :check_content_consistency do
  def check_content(checker, base_path)
    errors = checker.call(base_path)

    if errors.any?
      puts "#{base_path} 😱"
      puts errors
    end

    errors.none?
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
    failures = items.reject do |base_path|
      check_content(checker, base_path)
    end
    puts "Results: #{failures.count} failures out of #{items.count}."
  end
end
