# Content Store API

## Content items

`ContentItem` is the base unit of content in the content store. They have both a
private and public-facing JSON representation. More details on these
representations and the meanings of the individual fields can be found in
[content_item_fields.md](content_item_fields.md).

## Writing content items to the content store

Content is written by the [publishing API](https://docs.publishing.service.gov.uk/apps/publishing-api.html), which is used by back-end publishing apps such as Travel Advice Publisher.

To add or update a piece of content in the content store, make a PUT request:

``` sh
curl https://content-store.publishing.service.gov.uk/content<base_path> -X PUT \
    -H 'Content-type: application/json' \
    -d '<content_item_json>'
```

where `<base_path>` is the path on GOV.UK where the content lives (for example
`/vat-rates`) and `<content_item_json>` is the JSON for the content item as
outlined in [input_examples](input_examples).

There is currently an [API adapter](https://github.com/alphagov/gds-api-adapters/blob/master/lib/gds_api/publishing_api.rb)
in [gds-api-adapters](https://github.com/alphagov/gds-api-adapters) for writing
content to content-store, although it is likely that this will soon be extracted
to a separate gem.

## Reading content from the content store

Content is retrieved from the content store via the [content API](https://content-api.publishing.service.gov.uk/), which takes a path and responds with a JSON representation of the content that should be displayed on that path. This API is used by front-end apps but is also exposed externally at `/api/content/<path>`, such as https://www.gov.uk/api/content/take-pet-abroad

To retrieve content from the content store, make a GET request:

``` sh
  curl https://content-store.publishing.service.gov.uk/content<path>
```

If the `path` matches a `base_path` content will be returned, whereas if the
`path` matches a route a 303 redirect will be returned to the content at the
`base_path`.

Examples of the JSON representation of content items can be found in [output_examples](output_examples).

Not all content exists as a standalone page like the `/take-pet-abroad` example. Some content exists as a collection that references other pieces of content, and some content exists as meta content designed to describe a wider whole. We use [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas) to describe all these different content types. The content API itself is not prescriptive about this; it takes any JSON structure.
