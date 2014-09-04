# Document format

A document consists of a set key/value pairs. Different key/value pairs are
present or required, depending on the context. The three contexts are:

 - storing: Documents being sent to the content store.
 - retrieving: Documents being retrieved from the content store.
 - notifying: Messages notifying listeners about changes to the content store.

Examples of documents as sent to the content store can be found in
[`input_examples`](input_examples/).  Examples of documents output from the
content store API can be found in [`output_examples`](output_examples/).

# Details of each field

## `base_path`

A string. Present in all contexts.

The absolute path on GOV.UK for the content.  This is a unique identifier
within the content store, used to find content in the content store to answer
the question "what is at this URL?".

## `format`

A string. Present in all contexts.

The format of the content.  This determines how the contents of the `details`
field should be interpreted by the owning app.

Some formats are specially handled by the content store, and expect a different
set of fields than those listed below.

 - `gone`: A document which has [gone away](input_examples/gone_item.md)
 - `redirect`: A document which has [been redirected](input_examples/redirect_item.md)

## `content_id`

An UUID string as described in [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).
Present in all contexts.

For example: `"30737dba-17f1-49b4-aff8-6dd4bff7fdca"`.

TODO: confirm that it'll be present in retrieving contexts.

TODO: confirm whether a `guid` is required for `redirect` and `gone` formats.

This is a unique identifier for the piece of context, allocated by the
publishing app.

It will not change, and allows us to handle changes to paths and slugs on the
site without breaking references.  In particular, it is used by the `tags`
field to refer to other content.

The content store does not validate that the `guid` value is unique within the
store.  This is because a single piece of content may be published to multiple
paths at once (though this should usually only be done temporarily, giving time
to ensure that content is available at a new path before replacing the content
at the old path with a redirect)

## `title`

A string. Present in all contexts.

The title for the content.  This will be used, for example, for the HTML title
of the content when formatted as HTML, but may also be used when linking to the
content (eg, in search results).

## `description`

A string. Present in all contexts.

The description for the content.  This will be used, for example, for the HTML
meta-description of the content when formatted as HTML, but may also be used
when linking to the content (eg, in search results).

## `need_ids`

An array of strings. Present in all contexts.

An array of need ids associated with the content.  These should be strings
(though will typically be integers encoded as decimal strings); eg "100001".

Note: currently needs are not published on GOV.UK, so there won't be an entry
in the content store for them.  If this changes in future, the `need_ids` field
may be replaced by using the `tags` field to store this relation.

## `public_updated_at`

ISO 8601 formatted timestamp.  Present in all contexts.

This is the time at which the content was last publically visibly
updated.  This can be used for sorting by update date, but will not be changed
for minor updates.

## `details`

A hash.  Present in all contexts.

This hash contains information representing the content of the document.  The
meaning of the data here is dependent on the value of the `format` field.  The
interpretation of keys which exist here should be consistent for a given format
(though there may be optional ones for each format).

## `tags`

A hash.  Present in all contexts, but representations vary.

Tags represent links from items in the content store to other items in the
content store (or items which will be in the content store once published).
For example, links to mainstream browse pages, topics, organisations and other
things associated with the content.

For example:

    "tags": {
      "organisations": ['ORG-CONTENT-ID', 'ANOTHER-ORG-CONTENT-ID'],
      "topics": ['TOPIC-CONTENT-ID'],
    }

The keys here represent the type of the tag (for example, "topics").  The value
is a list of associated items, in which order may be significant; the content
store will preserve the order.

In the `storing` context, the items are UUID strings.

In the `notifying` context, the items are hashes containing: (TODO: confirm)
 - `guid`: The GUID of the tagged document
 - `base_path`: The base path of the document

In the `retrieving` context, the items are hashes containing: (TODO: confirm)
 - `guid`: The GUID of the document
 - `base_path`: The base path of the document
 - `title`: The title of the document
 - In future, there may be optional API parameters to request that other fields
   from the linked document are included in this hash (eg, title, description).

## `updated_at`

ISO 8601 formatted timestamp.  Present in retrieving and notifying contexts.

Note: This field is set by the content store whenever a document is created or
modified in it.

It contains the timestamp at which the content was last modified in any way.
This is suitable to be used for update versioning.

## `publishing_app`

A string.  Present only in storing context.

This is the name of the application responsible for publishing the document to
the content store.  This should be resolvable with
`Plek.new.find(publishing_app)`.

## `rendering_app`

A string.  Present only in storing context.

The is the name of the application responsible for rendering the document on
the site.  It will be passed on to the router when the content store is
registering routes for the content.  This should be resolvable with
`Plek.new.find(rendering_app)`.

## `routes`

An array of hashes.  Present only in storing context.

This holds the routes associated with the document.  Each hash in the array
contains a path and a routing type.  See
[`route_registration`](input_examples/route_registration.md) for more details.

## `redirects`

An array of hashes.  Present only in storing context.

TODO: this field may only be valid for documents of format `redirect`; decision to be
made.

The redirects from old paths associated with the document.  Each hash in the
array contains an original path, a routing type, and an optional destination
path.  See [`route_registration`](input_examples/route_registration.md) for
more details.

## `update_type`

A string.  Present in storing and notifying contexts.

This indicates what type of update the change to the document is.
It must be one of:

 - 'major' - major changes to a piece of content.
 - 'minor' - changes which don't affect the meaning of the
   content, eg typo correction.
 - 'republish' - useful in situations such as when the data
   structure has changed.

Other types may be added in future, content-store will just pass them through
to the fanout.
