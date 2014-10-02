## Gone items

To represent content that is no longer available, the content-store will support items with a format
of "gone".  These will cause a gone route to be setup in the router so that the item returns a 410
HTTP status.

Items with a format of gone will have all routes setup in the same way as other item types (described in
route_registration.md), with the exception that instead of routing to the rendering_app, routes will be
created as gone routes.

For example, given an item including the following fields:

    {
      "base_path": "/gone-foo",
      "format": "gone",
      "routes": [
        {"path": "/gone-foo", "type": "exact"},
        {"path": "/gone-foo/bar", "type": "exact"}
      ]
    }

The following route would be created:

    /gone-foo (exact) => gone
    /gone-foo/bar (exact) => gone
