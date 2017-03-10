# The content store

The central storage of *published* content on GOV.UK.

## Technical documentation

The content store maps public-facing URLs to published items of content,
represented as JSON data. It will replace [content API][content-api]
in time.

Publishing applications add content to the content store via the Publishing API;
public-facing applications read content from the content store and render them
on GOV.UK.

## Running the application

`./startup.sh`

## Running the test suite

`bundle exec rake`

## Example API output

Example API requests and corresponding responses can be found in the
[content store pack-broker documentation][pact-broker-docs].

## Licence

[MIT License](LICENCE)

## Further technical information

Detailed technical information can be found in the
[content store documentation](doc/technical-information.md).

[content-api]: https://github.com/alphagov/govuk_content_api
[pact-broker-docs]: https://pact-broker.cloudapps.digital/pacts/provider/Content%20Store/consumer/Publishing%20API/latest
