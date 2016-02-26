#!/bin/bash -x
set -e

export RAILS_ENV=test

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

if [[ ${GIT_BRANCH} != "origin/master" ]]; then
  bundle exec govuk-lint-ruby \
    --diff \
    --cached \
    --format html --out rubocop-${GIT_COMMIT}.html \
    --format clang \
    app config Gemfile lib script spec
fi

bundle exec rake db:mongoid:drop
COVERAGE=on bundle exec rake ci:setup:rspec default
