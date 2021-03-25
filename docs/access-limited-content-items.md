# Access-limited content items

Some content can be marked as [access-limited](content_item_fields.md#access_limited).
This content can only be retrieved from the content store with the right
authorisation. Authentication details can be provided with a GET request to
identify an authenticated user:

``` sh
  curl -header "X-Govuk-Authenticated-User: f17150b0-7540-0131-f036-0050560123202" \
    https://content-store.publishing.service.gov.uk/content<base_path>

```

If the supplied identifier is in the list of authorised users, the content item
will be returned. If not, a 403 (Forbidden) response will be returned.

Note: the access-limiting behaviour should only be active on the draft stack.
