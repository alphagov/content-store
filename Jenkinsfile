#!/usr/bin/env groovy

library("govuk")

node("mongodb-2.4") {
  govuk.buildProject(
    extraParameters: [
      stringParam(
        name: "PACT_CONSUMER_VERSION",
        defaultValue: "branch-deployed-to-production",
        description: "The branch of Publishing API pact tests to run against"
      ),
      stringParam(
        name: "PACT_BROKER_BASE_URL",
        defaultValue: "https://pact-broker.cloudapps.digital",
        description: "The Pact Broker to run Pact tests against"
      ),
    ],
  )
}
