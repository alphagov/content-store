begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:pact_verify) do |task|
    task.pattern = "spec/pact/consumers/**/*_spec.rb"
    task.rspec_opts = "--require rails_helper --tag pact"
  end

  namespace :pact do
    desc "Pact verification"
    task verify: :pact_verify
  end
rescue LoadError
  # Pact isn't available in all environments
end

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  # Rubocop isn't available in all environments
end

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[rubocop spec pact:verify]
