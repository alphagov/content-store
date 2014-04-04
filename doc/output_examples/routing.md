
## Routes for content:

Within the app, the details for an item of content will live at:

    https://content-store.production.alphagov.co.uk/content/<base_path>

eg

    https://content-store.production.alphagov.co.uk/content/vat-rates
    https://content-store.production.alphagov.co.uk/content/government/organisations/cabinet-office

We could have an optional .json suffix.

## Public API endpoint.

This would end up being surfaced to the public at:

    https://www.gov.uk/api/content/<base_path>

eg

    https://www.gov.uk/api/content/vat-rates
    https://www.gov.uk/api/content/government/organisations/cabinet-office
