# Content Store

The central storage of *published* content on GOV.UK.

Content Store maps public-facing URLs to published items of content, represented
as JSON data. It will replace [content API](https://github.com/alphagov/govuk_content_api)
in time.

Publishing applications add content to Content Store; public-facing
applications read content from Content Store and render them on GOV.UK.

## Content items

`ContentItem` is the base unit of content in Content Store. They have both a
private and public-facing JSON representation. More details on these
representations and the meanings of the individual fields can be found in
[doc/content_item_fields.md](doc/content_item_fields.md).

## Writing content items to Content Store

Publishing applications will "publish" content on GOV.UK by sending them to
Content Store. To add or update a piece of content in Content Store, make a PUT
request:

``` sh
curl https://content-store.production.alphagov.co.uk/content/<base_path> -X PUT \
    -H 'Content-type: application/json' \
    -d '<content_item_json>'
```

where `<base_path>` is the path on GOV.UK where the content lives (for example
`/vat-rates`) and `<content_item_json>` is the JSON for the content item as
outlined in [doc/input_examples](doc/input_examples).

## Reading content from Content Store

To retrieve content from Content Store, make a GET request:

``` sh
  curl https://content-store.production.alphagov.co.uk/content/<base_path>
```

Examples of the JSON representation of content items can be found in [doc/output_examples](doc/output_examples).

## Post publishing/update notifications

After a content item is added or updated, a message is published to RabbitMQ.
It will be published to the `published_documents` topic exchange with the
routing_key `"#{item.format}.#{item.update_type}"`. Interested parties can
subscribe to this exchange to perform post-publishing actions. For example, a
search indexing service would be able to add/update the search index based on
these messages. Or an email notification service would be able to send email
updates.

The message body will be the public-facing JSON representation of the content
item as outlined in the [output example](doc/output_examples/generic.json) with
the addition of the `update_type` field (NOTE: subject to change).
