# The content store

The Content Store is a MongoDB database of almost all published content on GOV.UK.

## Reading and writing to the store

Content is retrieved from the content store via the [content API][content-api-docs],
which takes a path and responds with a JSON representation of the content that should
be displayed on that path. This API is used by front-end apps but is also exposed externally
at `/api/content/<path>`, such as https://www.gov.uk/api/content/take-pet-abroad

Content is written by the [publishing API][publishing-api-docs], which is used by
back-end publishing apps such as Travel Advice Publisher.

### Content schemas

Not all content exists as a standalone page like the `/take-pet-abroad` example. Some
content exists as a collection that references other pieces of content, and some content
exists as meta content designed to describe a wider whole. We use
[govuk-content-schemas] to describe all these different content
types. The content API itself is not prescriptive about this; it takes any JSON structure.

Detailed technical information can be found in the
[content store documentation][content-store-docs].

## Running the application

`./startup.sh`

## Running the test suite

`bundle exec rake`

## Example API output

Example API requests and corresponding responses can be found in the
[content store pact-broker documentation][pact-broker-docs].

## Licence

[MIT License](LICENCE)

[content-api-docs]: https://content-api.publishing.service.gov.uk/
[content-store-docs]: https://github.com/alphagov/content-store/blob/master/doc/technical-information.md
[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[pact-broker-docs]: https://pact-broker.cloudapps.digital/pacts/provider/Content%20Store/consumer/Publishing%20API/latest
[publishing-api-docs]: https://docs.publishing.service.gov.uk/apps/publishing-api.html
