# The content store

The central storage of *published* content on GOV.UK.

## Technical documentation

The content store maps public-facing URLs to published items of content,
represented as JSON data. It will replace [content API](https://github.com/alphagov/govuk_content_api)
in time.

Publishing applications add content to the content store via the Publishing API;
public-facing applications read content from the content store and render them
on GOV.UK.

## Running the application

`./startup.sh`

## Running the test suite

`bundle exec rake`

## Example API output

Example API requests and corresponding responses can be found in the [content store pack-broker documentation](https://pact-broker.dev.publishing.service.gov.uk/pacts/provider/Content%20Store/consumer/Publishing%20API/latest).

## Licence

[MIT License](LICENCE)

## Further technical information

Detailed technical information can be found in the [content store documentation](doc/technical-information.md).
