#!/bin/bash

export REPO_NAME="alphagov/govuk-content-schemas"
export CONTEXT_MESSAGE="Verify content-store against content schemas"

exec ./jenkins.sh
