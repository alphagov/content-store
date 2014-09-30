# The Content Item Format

A content item consists of a set key/value pairs. Different key/value pairs are
present or required, depending on the context. The three contexts are:

 - storing: content items being sent to the content store.
 - retrieving: content items being retrieved from the content store.
 - notifying: Messages notifying listeners about changes to content items.

Examples of content items as sent to the content store can be found in
[`input_examples`](input_examples/). Examples of content items being retrieved
from the content store API can be found in
[`output_examples`](output_examples/).

# Details of each field

## `base_path`

A string. Present in all contexts.

The absolute path of the content on GOV.UK. This uniquely identifies the
content within the content store and allows the content store to answer the
question "what is at this URL?".

## `format`

A string. Present in all contexts.

The format of the content. This determines how the contents of the `details`
field should be interpreted by the public-facing application responsible for
rendering the content on GOV.UK.

Some formats are explicitly handled by the content store, and expect a different
set of fields than those listed below.

 - `gone`: A content item which has [gone away](input_examples/gone_item.md)
 - `redirect`: A content item which has [been redirected](input_examples/redirect_item.md)

## `content_id`

A UUID string as described in [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).
Present only in the storing context.

For example: `"30737dba-17f1-49b4-aff8-6dd4bff7fdca"`.

This is a unique identifier for the piece of content, allocated by the
publishing application. It is used as the reference with which content items can
reference other content items (see the `links` field in the input/output
examples).

The content store does not enforce the uniqueness of `content_id` values within
the store. This is because more than one content item may exist in the content
store for the same `content_id`. This will usually only ever be temporary
during the creation of a redirect to ensure that the new content is available
before the redirect replaces the old content.

## `title`

A string. Present in all contexts.

The title for the content. This will be used, for example, for the HTML title
of the content when formatted as HTML, but may also be used when linking to the
content (eg, in search results).

## `description`

A string. Present in all contexts.

The description of the content. This will be used, for example, for the HTML
meta-description of the content when formatted as HTML, but may also be used
when linking to the content (eg, in search results).

## `need_ids`

An array of strings. Present in all contexts.

An array of need ids associated with the content. These should be strings
(though will typically be integers encoded as decimal strings); eg "100001".

Note: currently needs are not published on GOV.UK, so there won't be an entry
in the content store for them. If this changes in future, the `need_ids` field
may be replaced by using the `links` field to store this relation.

## `public_updated_at`

ISO 8601 formatted timestamp. Present in all contexts.

This is the time at which the content was last publicly visibly updated. This
can be used for sorting by update date, but will not be changed for minor
updates.

## `details`

A hash. Present in all contexts.

This hash contains information representing the main content of the content
item. The meaning of the data here is dependent on the value of the `format`
field. The interpretation of keys which exist here should be consistent for a
given format (though there may be optional ones for each format).

## `links`

A hash. Present in all contexts, but representations vary.

Links represent related content items. These may or may not actually exist in
the content store yet, depending on whether the content has been published or
not.

For example:

    "links": {
      "organisations": ['ORG-CONTENT-ID', 'ANOTHER-ORG-CONTENT-ID'],
      "topics": ['TOPIC-CONTENT-ID'],
    }

The keys here represent the format type of the link (for example, "topics").
The value is a list of associated items, the order of which may be significant;
content store preserves the order.

In the `storing` context, the items are UUID strings.

In the `notifying` context, the items are hashes containing: (TODO: confirm)
 - `content_id`: The Content ID of the linked content item
 - `base_path`: The base path of the content item

In the `retrieving` context, the items are hashes containing:
 - `title`: The title of the content item
 - `base_path`: The base path of the content
 - `api_url`: The URL from at which content item is retrievable from the content
              store
 - `web_url`: The public-facing URL for the piece of content

## `updated_at`

ISO 8601 formatted timestamp. Present in retrieving and notifying contexts.

Note: This field is set by the content store whenever a item is created or
modified in it.

It contains the timestamp at which the content was last modified in any way.
This is suitable to be used for update versioning.

## `publishing_app`

A string. Present only in storing context.

This is the name of the application responsible for publishing the content to
the content store. This should be resolvable with
`Plek.new.find(publishing_app)`.

## `rendering_app`

A string. Present only in storing context.

The is the name of the application responsible for rendering the content on
GOV.UK. It is passed to the router when the content store registers the routes
for the content. This should be resolvable with `Plek.new.find(rendering_app)`.

## `routes`

An array of hashes. Present only in storing context.

This holds the routes associated with the content item. Each hash in the array
contains a path and a routing type. See
[`route_registration`](input_examples/route_registration.md) for more details.

## `redirects`

An array of hashes. Present only in storing context.

The redirects from old paths associated with the content item. Each hash in the
array contains an original path, a routing type, and an optional destination
path. See [`route_registration`](input_examples/route_registration.md) for
more details.

TODO: Currently, redirects for normal content can be registered with the
content item itself. We need to decide if this is what we want, or whether
redirects are only included in `redirect` content items.

## `update_type`

A string. Present in storing and notifying contexts.

This indicates the type of update that was made to the content item.
It must be one of:

 - 'major' - major changes to a piece of content.
 - 'minor' - changes which don't affect the meaning of the
   content, eg typo correction.
 - 'republish' - useful in situations such as when the data
   structure has changed.

Other types may be added in future, content-store will just pass them through
to the fanout.
