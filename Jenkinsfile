#!/usr/bin/env groovy

node("mongodb-2.4") {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'
  govuk.buildProject(
    extraParameters: [
      stringParam(
        name: "PUBLISHING_API_PACT_BRANCH",
        defaultValue: "deployed-to-production",
        description: "The branch of Publishing API pact tests to run against"
      ),
    ],
    beforeTest: {
      govuk.setEnvar("PACT_BROKER_BASE_URL", "https://pact-broker.cloudapps.digital")
    },
    publishingE2ETests: true,
    afterTest: {
      govuk.runRakeTask("pact:verify:branch[${env.PUBLISHING_API_PACT_BRANCH}]")
    }
  )
}
