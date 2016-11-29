#!/bin/bash -x
set -e

export RAILS_ENV=test

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

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
export GOVUK_CONTENT_SCHEMAS_PATH=/tmp/govuk-content-schemas

bundle exec rake db:mongoid:drop
COVERAGE=on bundle exec rake ci:setup:rspec default
