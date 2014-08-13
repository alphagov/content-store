## Redirect items

To represent content that can be found under a different base_path, the content-store will support
items with a format of "redirect".  Items with a format of "redirect" must include a redirect for
the base_path in their redirects array.  They may include other paths under the base_path in addition.

For redirect items, the routes array and rendering_app will be ignored, and should be left empty.

For example, given an item including the following fields:

    {
      "base_path": "/moved-foo",
      "format": "redirect",
      "update_type" => "major",
      "redirects": [
        {"path": "/moved-foo", "type": "prefix", "destination": "/new-foo"},
        {"path": "/moved-foo.json", "type": "exact", "destination": "/api/moved-foo.json"}
      ]
    }

The following redirects would be created:

    /moved-foo (prefix) => /new-foo
    /moved-foo.json (exact) => /api/moved-foo.json
