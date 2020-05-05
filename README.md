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

## Limitations of the content API

- Not all content is in the content-store yet. There are pages that
don't use the publishing platform and can't be found in the content store
(at the time of writing, [pages about past prime ministers][past-prime-ministers]).
- For some pages the content store will not return all the content on the page (an
[organisation page][organisation-page] for example).
- Not all content in the store has a publicly queryable path, e.g. facets. They can
only be queried via their ID, using the search API:
  - https://www.gov.uk/api/search.json?filter_content_id=894a7c88-40bb-46-a234-b7e15d8a0c21
  - https://www.gov.uk/api/search.json?filter_facet_values=77764805-73e6-4d47-9f20-aedd6de7dab9

[organisation-page]: https://www.gov.uk/api/content/government/organisations/hm-revenue-customs
[past-prime-ministers]: https://www.gov.uk/government/history/past-prime-ministers/gordon-brown

## Licence

[MIT License](https://github.com/alphagov/content-store/blob/master/LICENSE)

[content-api-docs]: https://content-api.publishing.service.gov.uk/
[content-store-docs]: https://github.com/alphagov/content-store/blob/master/doc/technical-information.md
[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[pact-broker-docs]: https://pact-broker.cloudapps.digital/pacts/provider/Content%20Store/consumer/Publishing%20API/latest
[publishing-api-docs]: https://docs.publishing.service.gov.uk/apps/publishing-api.html
