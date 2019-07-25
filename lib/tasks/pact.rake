return if Rails.env.production?

require 'pact/tasks'
require 'pact/tasks/task_helper'

desc "Verifies a particular branch of Publishing API against pacts"
task "pact:verify:branch", [:branch_name] do |t, args|
  abort "Please provide a branch name. eg rake #{t.name}[my_feature_branch]" unless args[:branch_name]

  pact_version = args[:branch_name] == "master" ? args[:branch_name] : "branch-#{args[:branch_name]}"

  ClimateControl.modify PUBLISHING_API_PACT_VERSION: pact_version, USE_LOCAL_PACT: nil do
    Pact::TaskHelper.handle_verification_failure do
      Pact::TaskHelper.execute_pact_verify
    end
  end
end
