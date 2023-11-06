#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("TEST_DATABASE_URL", "postgresql://postgres@127.0.0.1:54313/content_store_test")

  govuk.buildProject(
    extraParameters: [
      stringParam(
        name: "PACT_CONSUMER_VERSION",
        defaultValue: "branch-deployed-to-production",
        description: "The branch of Publishing API pact tests to run against"
      ),
      stringParam(
        name: "PACT_BROKER_BASE_URL",
        defaultValue: "https://govuk-pact-broker-6991351eca05.herokuapp.com",
        description: "The Pact Broker to run Pact tests against"
      ),
    ],
  )
}
