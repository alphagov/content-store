## Registering routes with the router.

After saving an item, the content store will register routes with the router.
All items listed in the routes array will be created as routes pointing at the
`rendering_app`. The routes for a content item must contain a route for the
`base_path`.

All entries in the routes array must be under the `base_path` (ie either a
subpath of the `base_path`, or the `base_path` with an extension)

Given a request including the following fields:

    PUT /content/foo
    {
      "rendering_app": "frontend",
      "routes": [
        {"path": "/foo", "type": "exact"},
        {"path": "/foo.json", "type": "exact"},
        {"path": "/foo/subpath", "type": "prefix"},
        {"path": "/foo/other/path", "type": "exact"}
      ]
    }

The following routes would be created:

    /foo (exact) => frontend
    /foo.json (exact) => frontend
    /foo/subpath (prefix) => frontend
    /foo/other/path (exact) => frontend

### Placeholder items

Items with a format starting with "placeholder" will not have the routes
registered with the router.

### Redirects for subpaths

The content store can also create redirects for paths under the base_path.  This is intended to support
cases where the structure within a piece of content has changed (eg a part of a guide no longer exists.)

**Note:** the redirects array must not include the base_path.  The only exception is redirect items,
which are described in redirect_item.md.

Redirects are specified in the redirects array, and specify a destination as well as a path and type.

e.g. given a request including the following fields:

    PUT /content/foo
    {
      "redirects": [
        {"path": "/foo.json", "type": "exact", "destination": "/api/foo.json"},
        {"path": "/foo/obsolete-part", "type": "exact", "destination": "/foo"}
      ]
    }

The following redirects will be created:

    /foo.json (exact) => /api/foo.json
    /foo/obsolete-part (exact) => /foo
