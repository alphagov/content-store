# Publish intents

In order to support the timely publishing of items that are scheduled for
publication, it is necessary for the cache control headers to be reduced as the
publish time approaches.  To allow this to happen, content-store allows
publishing apps to register an "intent to publish" for a given content-item.

When serving a content-item, if an upcoming publishing intent exists,
content-store will serve the content item with the cache headers reduced
accordingly.  If no content-item exists for the publish intent, content-store
will return a 404, but will still set the cache headers accordingly.

The downstream apps respect content-store's cache headers, so this will be
propagated out.

## Publish intent format

A publish intent has the following fields:

* `base_path` - The path of the item that will be published. Found in the
request URL of write requests and the response body for read requests.
* `publish_time` - ISO 8601 formatted timestamp. The time the corresponding
  content item will be published.
* `publishing_app` - The publishing app that owns this content (see
  [content_item_fields.md#publishing_app](content_item_fields.md#publishing_app)
  for details)
* `rendering_app` - The app that will render this content (see
  [below](#routing-for-a-publish-intent) for details)
* `routes` - The routes for this content (see
  [below](#routing-for-a-publish-intent) for details)

For example:

``` js
PUT /publish-intent/vat-rates
{
  "publish_time": "2015-01-05T09:00:00+00:00",
  "publishing_app": "publisher",
  "rendering_app": "frontend",
  "routes": [
    {"path": "/vat-rates", "type": "exact"}
  ]
}
```

## Routing for a publish intent

A publish intent requires both a `rendering_app` and `routes` in the same way
as a content item.  See [route_registration.md](route_registration.md) for
details of these fields.

When a publish intent is created, content-store will register any routes for it
that don't already exist on the corresponding content item (if no content item
exists, all the routes will be registered).  This is necessary so that incoming
requests make it as far as the rendering app, and can therefore have cache
headers set as necessary.

## Registering an intent to publish

Publishing applications will submit an intent to publish by sending them to the
content store. To add or update an intent make a PUT request:

``` sh
curl https://content-store.publishing.service.gov.uk/publish_intents<base_path> \
  -X PUT \
  -H 'Content-type: application/json' \
  -d '<publish_intent_json>'
```

where `<base_path>` is the path on GOV.UK where the content will live (for
example /vat-rates) and `<publish_intent_json>` is the JSON for the publish
intent as outlined above.

This will return a 200 or 201 (for update, or create) on success.  It will
return a 422 along with error details for any validation failures. It will
return a 409 if the `base_path` is already registered to a different
`publishing_app`.

## Querying details of a publish intent

Details of a publish intent can be queried by making a GET request:

``` sh
curl https://content-store.publishing.service.gov.uk/publish_intents<base_path>
```

This will return a 200 along with the details of the intent as JSON, ot a 404
if a matching intent wasn't found.

## Deleting an intent to publish

There's no need to delete publish intents for the normal workflow - past
publish intents are automatically deleted by a nightly housekeeping job.

A publishing application can explicitly delete an intent to publish (for
example if an editor cancels a scheduled publishing) by sending a DELETE
request:

``` sh
curl https://content-store.publishing.service.gov.uk/publish_intents<base_path> -X DELETE
```

This will remove the intent for the corresponding `base_path`.  It will return
200 along with the intent details as JSON on success, or 404 if no matching
intent existed.
