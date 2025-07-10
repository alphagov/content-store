# Content Store API

## Content items

`ContentItem` is the base unit of content in the content store. They have both a private and public-facing JSON representation.

## Writing content items to the content store

Content is written by the [Publishing API](https://docs.publishing.service.gov.uk/apps/publishing-api.html), which is used by back-end publishing apps such as Travel Advice Publisher.

Within our infrastructure, to add or update a piece of content in the content store, make a PUT request:

``` sh
curl http://content-store/content<base_path> -X PUT \
    -H 'Content-type: application/json' \
    -d '<content_item_json>'
```

where `<base_path>` is the path on GOV.UK where the content lives (for example `/vat-rates`) and `<content_item_json>` is the JSON for the content item.

## Reading content from the content store

Content is retrieved using the `content` endpoint, which takes a path and responds with a JSON representation of the content that should be displayed on that path.

This API is used by front-end apps but is also exposed externally at `https://www.gov.uk/api/content/<path>`, such as [https://www.gov.uk/api/content/take-pet-abroad](https://www.gov.uk/api/content/take-pet-abroad). When used by the public, this is known as 'Content API' and has [its own documentation](https://content-api.publishing.service.gov.uk/).

Within our infrastructure, to retrieve content from the Content Store, make a GET request:

``` sh
  curl http://content-store/content<path>
```

If the `path` matches a `base_path` content will be returned, whereas if the `path` matches a route a 303 redirect will be returned to the content at the `base_path`.

Not all content exists as a standalone page like the `/take-pet-abroad` example. Some content exists as a collection that references other pieces of content, and some content exists as meta content designed to describe a wider whole. We use [content-schemas defined in Publishing API](https://github.com/alphagov/publishing-api/tree/main/content_schemas) to describe all these different content types. The Content API itself is not prescriptive about this; it takes any JSON structure.
