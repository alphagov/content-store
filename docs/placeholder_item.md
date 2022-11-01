## Placeholder items

Items not yet being served from the content store, but that need to be linked to and
referenced from other content items in the content store.

During the transition to using the content store as the source of published
content on GOV.UK, there may be a need to link to content that isn't yet being
served directly from the content store. In such cases, the content that needs
to be linked to can be added to the content store with a schema_name of
"placeholder" and a document_type of either "placeholder" or
prefixed with "placeholder_".  Placeholder content
will be expanded out when linked to in the `links` field of a content item, and
can also be retrieved from the content store, but will not have its routes
registered or updated.
