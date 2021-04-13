#!/usr/bin/env groovy

library("govuk")

node("mongodb-2.4") {
  govuk.buildProject(
    extraParameters: [
      stringParam(
        name: "PACT_CONSUMER_VERSION",
        defaultValue: "deployed-to-production",
        description: "The branch of Publishing API pact tests to run against"
      ),
    ],
    beforeTest: {
      govuk.setEnvar("PACT_BROKER_BASE_URL", "https://pact-broker.cloudapps.digital")
    },
    publishingE2ETests: true,
    afterTest: {
      stage("Test pact with Publishing API") {
        govuk.runRakeTask("pact:verify")
      }
    }
  )
}
