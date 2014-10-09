## Placeholder items

Items not yet being served from content-store, but that need to be linked to and
referenced from other content items in content-store.

During the transition to using content-store as the source of published content
on GOV.UK, there may be a need to link to content that isn't yet being served
directly from the content-store. In such cases, the content that needs to be
linked to can be added to content-store with a format of "placeholder".
"placeholder" content will be expanded out when linked to in the `links` field
of a content item, and can also be retrieved from content-store, but will not
have its routes registered or updated.
