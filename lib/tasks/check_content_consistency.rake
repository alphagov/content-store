namespace :check_content_consistency do
  def check_content(base_path, ignore_recent = false)
    checker = ContentConsistencyChecker.new(base_path, ignore_recent)
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
  task :all, [:ignore_recent] => [:environment] do |_, args|
    items = ContentItem.pluck(:base_path)
    failures = items.reject do |base_path|
      check_content(
        base_path,
        args.fetch(:ignore_recent, false) == "true"
      )
    end
    puts "Results: #{failures.count} failures out of #{items.count}."
  end
end
