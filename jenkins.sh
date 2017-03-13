#!/bin/bash

set -e

export RAILS_ENV=test
export GOVUK_CONTENT_SCHEMAS_PATH=/tmp/govuk-content-schemas
export COVERAGE=on
export PACT_BROKER_BASE_URL=https://pact-broker.cloudapps.digital

# Cleanup anything left from previous test runs
git clean -fdx

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment --without development

bundle exec govuk-lint-ruby \
  --format html --out rubocop-${GIT_COMMIT}.html \
  --format clang \
  app config Gemfile lib script spec

# Clone govuk-content-schemas depedency for contract tests
rm -rf /tmp/govuk-content-schemas
git clone git@github.com:alphagov/govuk-content-schemas.git /tmp/govuk-content-schemas
(
 cd /tmp/govuk-content-schemas
 git checkout ${SCHEMA_GIT_COMMIT:-"deployed-to-production"}
)

bundle exec rake db:mongoid:drop

bundle exec rake ci:setup:rspec default
