# Content Store

The Content Store is a MongoDB database of almost all published content on GOV.UK.
See the [Content Store API](./docs/content-store-api.md) for basic usage.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

`bundle exec rake`

### Example API output

Example API requests and corresponding responses can be found in the
[content store pact-broker documentation](https://pact-broker.cloudapps.digital/pacts/provider/Content%20Store/consumer/Publishing%20API/latest).

## Further documentation

- [Content Store API](./docs/content-store-api.md)
- [Publish intents](./docs/publish_intents.md)
- [Access-limited content items](./docs/access-limited-content-items.md)
- [Gone items](./docs/gone_item.md)
- [Redirect items](./docs/redirect_item.md)
- [Placeholder items](./docs/placeholder_item.md)

## Licence

[MIT License](https://github.com/alphagov/content-store/blob/master/LICENSE)
