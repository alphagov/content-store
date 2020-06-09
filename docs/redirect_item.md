## Redirect items

To represent content that can be found under a different `base_path`, the content store will support
items with a format of "redirect".  These items have slightly different rules:

* They must include a redirect for the `base_path` in their redirects array.
  They may additionally include other paths under the `base_path`.
* The `routes` array and `rendering_app` will be ignored, and should be left empty.
* A title is not required.

For example, given the following request:

    PUT /content/moved-foo
    {
      "format": "redirect",
      "publishing_app": "publisher",
      "redirects": [
        {"path": "/moved-foo", "type": "prefix", "destination": "/new-foo"},
        {"path": "/moved-foo.json", "type": "exact", "destination": "/api/moved-foo.json"}
      ]
    }

The following redirects would be created:

    /moved-foo (prefix) => /new-foo
    /moved-foo.json (exact) => /api/moved-foo.json
