# Content Store

The Content Store is a database of almost all published content on GOV.UK.
See the [Content Store API](./docs/content-store-api.md) for basic usage.

## Deployment in current transitional state

For most of 2023, Publishing Platform team have been working on migrating Content Store from MongoDB to PostgreSQL on Amazon's RDS service. This work is nearing completion, but at the moment there is a non-standard setup for deploying any changes.

* The `main` branch is currently _not in use by any deployed application_
* The `content-store` and `draft-content-store` applications in all environments are using a container name of `content-store`, but that must be manually built from the `port-to-postgresql` branch

If you need to deploy Content Store, make sure that you:
* base any pull requests off the `port-to-postgresql` branch (see PR #1085)
* merge any pull requests into the `port-to-postgresql` branch
* deploy by running the [Deploy workflow](https://github.com/alphagov/content-store/actions/workflows/deploy.yml)
* specify `port-to-postgresql` as the "Commit, tag or branch name to deploy"
* specify `content-store` as the "ECR repo name to push image to"



## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

`bundle exec rake`

### Example API output

Example API requests and corresponding responses can be found in the
[content store pact-broker documentation](https://govuk-pact-broker-6991351eca05.herokuapp.com/pacts/provider/Content%20Store/consumer/Publishing%20API/latest).

## Further documentation

- [Content Store API](./docs/content-store-api.md)
- [Publish intents](./docs/publish_intents.md)
- [Access-limited content items](./docs/access-limited-content-items.md)
- [Gone items](./docs/gone_item.md)
- [Redirect items](./docs/redirect_item.md)
- [Placeholder items](./docs/placeholder_item.md)

## Licence

[MIT License](LICENCE)
