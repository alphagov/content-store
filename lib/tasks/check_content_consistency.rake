namespace :check_content_consistency do
  def check_content(base_path)
    checker = ContentConsistencyChecker.new(base_path)
    errors = checker.call

    if errors.any?
      puts "#{base_path} 😱"
      puts errors
    end

    errors.none?
  end

  desc "Check items for consistency with the router-api"
  task :one, [:base_path] => [:environment] do |_, args|
    base_path = args[:base_path]
    check_content(base_path)
  end

  desc "Check all the items for consistency with the router-api"
  task all: :environment do
    items = ContentItem.pluck(:base_path)
    failures = items.reject do |base_path|
      check_content(base_path)
    end
    puts "Results: #{failures.count} failures out of #{docs.count}."
  end
end
