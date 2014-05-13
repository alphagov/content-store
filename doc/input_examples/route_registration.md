## Registering routes with the router.

After saving an item, the content-store will register routes with the router.  All items listed in the
routes array will be created as routes pointing at the rendering_app.  Additionally, if the base_path is
not included in the routes or redirects array, an exact route will be created for it also pointing at the rendering app.

All entries in the routes array must be under the base_path (ie either a subpath of the base_path, or the base_path with an extension)

Given an item including the following fields:

    {
      "base_path": "/foo",
      "rendering_app": "frontend",
      "routes": [
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

### Redirects

The content-store can also create redirects (again constrained to be under the base path).  Redirects can
optionally specify a destination path - if ommitted, this will default to the base_path.

e.g. given the following:

    {
      "base_path": "/foo",
      "rendering_app": "frontend",
      "redirects": [
        {"path": "/foo.json", "type": "exact", "destination": "/api/foo.json"},
        {"path": "/foo/obsolete-part", "type": "exact"}
      ]
    }

The following redirects will be created:

    /foo.json (exact) => /api/foo.json
    /foo/obsolete-part (exact) => /foo
