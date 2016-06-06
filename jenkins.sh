#!/bin/bash -x
set -e

export RAILS_ENV=test

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

rm -rf govuk-content-schemas
git clone https://github.com/alphagov/govuk-content-schemas

bundle exec govuk-lint-ruby \
  --format html --out rubocop-${GIT_COMMIT}.html \
  --format clang \
  app config Gemfile lib script spec

bundle exec rake db:mongoid:drop
SCHEMAS_DIRECTORY="govuk-content-schemas/dist" COVERAGE=on bundle exec rake ci:setup:rspec default
