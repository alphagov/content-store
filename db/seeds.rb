# Create a test user for GDS-SSO
User.find_or_create_by!(name: "Test User")

a = ContentItem.new
b = {
    "analytics_identifier": "null",
    "base_path": "/find-eu-exit-guidance-business",
    "content_id": "42ce66de-04f3-4192-bf31-8394538e0734",
    "document_type": "finder",
    "first_published_at": "2018-12-19T14:33:59.000+00:00",
    "locale": "en",
    "phase": "live",
    "public_updated_at": "2019-04-15T14:53:37.000+00:00",
    "publishing_app": "rummager",
    "publishing_scheduled_at": "null",
    "rendering_app": "finder-frontend",
    "scheduled_publishing_delay_seconds": "null",
    "schema_name": "finder",
    "title": "Find EU Exit guidance for your organisation",
    "updated_at": "2019-04-15T19:05:55.472Z",
    "withdrawn_notice": {},
    "publishing_request_id": "868-1555340018.918-10.3.3.1-390",
    "links": {
        "email_alert_signup": [
            {
                "api_path": "/api/content/find-eu-exit-guidance-business/email-signup",
                "base_path": "/find-eu-exit-guidance-business/email-signup",
                "content_id": "2818d67a-029a-4899-a438-a543d5c6a20d",
                "description": "You'll get an email each time EU Exit guidance is published.",
                "document_type": "finder_email_signup",
                "locale": "en",
                "public_updated_at": "2019-04-15T14:53:37Z",
                "schema_name": "finder_email_signup",
                "title": "Find EU Exit guidance for your organisation",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/find-eu-exit-guidance-business/email-signup",
                "web_url": "https://www.gov.uk/find-eu-exit-guidance-business/email-signup"
            }
        ],
        "ordered_related_items": [
            {
                "api_path": "/api/content/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit",
                "content_id": "705ff357-7e3a-49ae-823e-5d6c7078d350",
                "description": "If the UK leaves the EU without a Brexit deal, there will be changes that affect your food and drink business. Find out how you can prepare.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-04-10T15:37:16Z",
                "schema_name": "detailed_guide",
                "title": "The food and drink sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/european-and-domestic-funding-after-brexit",
                "base_path": "/guidance/european-and-domestic-funding-after-brexit",
                "content_id": "e9bf1cbb-fcba-485a-8e1b-bf36d195c7b1",
                "description": "When the UK leaves the EU there may be changes to how UK organisations, such as charities, businesses and universities are funded.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:47:00Z",
                "schema_name": "detailed_guide",
                "title": "European and domestic funding after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/european-and-domestic-funding-after-brexit",
                "web_url": "https://www.gov.uk/guidance/european-and-domestic-funding-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/regulations-and-standards-after-brexit",
                "base_path": "/guidance/regulations-and-standards-after-brexit",
                "content_id": "f026b0f9-ce9c-499a-a3cd-1ba9aad8f368",
                "description": "When the UK leaves the EU there may be changes to the requirements for placing certain products on the UK and EU markets.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Regulations and standards after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/regulations-and-standards-after-brexit",
                "web_url": "https://www.gov.uk/guidance/regulations-and-standards-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/intellectual-property-after-brexit",
                "base_path": "/guidance/intellectual-property-after-brexit",
                "content_id": "b0a8b221-b2cb-434c-abb8-1a7323fd1e05",
                "description": "Parts of UK intellectual property (IP) law will change when the UK leaves the EU.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Intellectual property after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/intellectual-property-after-brexit",
                "web_url": "https://www.gov.uk/guidance/intellectual-property-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/the-chemicals-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-chemicals-sector-and-preparing-for-eu-exit",
                "content_id": "d2c7d17e-adf5-4ea1-b16b-4db9f922190a",
                "description": "If the UK leaves the EU without a deal, and you are a company that makes, supplies or uses chemicals, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:34:44Z",
                "schema_name": "detailed_guide",
                "title": "The chemicals sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-chemicals-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-chemicals-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/oil-and-gas-production-and-preparing-for-eu-exit",
                "base_path": "/guidance/oil-and-gas-production-and-preparing-for-eu-exit",
                "content_id": "a5d2f87c-06ae-4cf0-bea7-3fc9746eddd9",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T18:44:00Z",
                "schema_name": "detailed_guide",
                "title": "Oil and gas production and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/oil-and-gas-production-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/oil-and-gas-production-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-aerospace-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-aerospace-sector-and-preparing-for-eu-exit",
                "content_id": "fae745d3-c5a5-4505-aa59-d257e4e938c1",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:58:18Z",
                "schema_name": "detailed_guide",
                "title": "The aerospace sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-aerospace-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-aerospace-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-construction-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-construction-sector-and-preparing-for-eu-exit",
                "content_id": "27952a1b-702d-4166-bd62-6538892f73c3",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:28:28Z",
                "schema_name": "detailed_guide",
                "title": "The construction sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-construction-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-construction-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-automotive-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-automotive-sector-and-preparing-for-eu-exit",
                "content_id": "88ad2f6e-fb1e-47c9-8201-fdb02f90542c",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:56:04Z",
                "schema_name": "detailed_guide",
                "title": "The automotive sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-automotive-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-automotive-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/operating-in-the-eu-after-brexit",
                "base_path": "/guidance/operating-in-the-eu-after-brexit",
                "content_id": "7dd1f3ec-04a9-4954-b7c1-b7fd531daafc",
                "description": "When the UK leaves the EU, the way businesses both offer services in the EU and operate will change. ",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Operating in the EU after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/operating-in-the-eu-after-brexit",
                "web_url": "https://www.gov.uk/guidance/operating-in-the-eu-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/public-sector-procurement-after-brexit",
                "base_path": "/guidance/public-sector-procurement-after-brexit",
                "content_id": "b1194956-d0dd-4353-a835-5c4650528e74",
                "description": "When the UK leaves the EU, there may be changes to how you sell goods or services to the UK public sector.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Public sector procurement after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/public-sector-procurement-after-brexit",
                "web_url": "https://www.gov.uk/guidance/public-sector-procurement-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/the-retail-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-retail-sector-and-preparing-for-eu-exit",
                "content_id": "f896235a-0cf0-4047-af75-926df45e1aa6",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:50:08Z",
                "schema_name": "detailed_guide",
                "title": "The retail sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-retail-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-retail-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/gas-markets-and-preparing-for-eu-exit",
                "base_path": "/guidance/gas-markets-and-preparing-for-eu-exit",
                "content_id": "1ecf3661-4bf0-4776-9cd6-7ecd5cffac2e",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-12T16:18:00Z",
                "schema_name": "detailed_guide",
                "title": "Gas markets and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/gas-markets-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/gas-markets-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/using-personal-data-after-brexit",
                "base_path": "/guidance/using-personal-data-after-brexit",
                "content_id": "2f6219da-6453-494f-bd5e-2e599642612d",
                "description": "When the UK leaves the EU there may be changes to the rules governing the use of personal data.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-06T15:10:00Z",
                "schema_name": "detailed_guide",
                "title": "Using personal data after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/using-personal-data-after-brexit",
                "web_url": "https://www.gov.uk/guidance/using-personal-data-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/energy-and-climate-after-brexit",
                "base_path": "/guidance/energy-and-climate-after-brexit",
                "content_id": "54b2b1e7-68a1-4df9-a9e4-70bcd0bcde71",
                "description": "When the UK leaves the EU there may be changes to areas including energy renewables, the nuclear industry and regulated carbon emissions.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-06T15:10:00Z",
                "schema_name": "detailed_guide",
                "title": "Energy and climate after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/energy-and-climate-after-brexit",
                "web_url": "https://www.gov.uk/guidance/energy-and-climate-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit",
                "base_path": "/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit",
                "content_id": "aff1b568-e23b-464b-bd24-5c0a0cd9bf27",
                "description": "When the UK leaves the EU there may be changes to UK-EU trade at the UK border including on customs, tariffs, VAT, safety and security, documentation, vehicle standards, and controlled products.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-22T16:04:52Z",
                "schema_name": "detailed_guide",
                "title": "Importing, exporting and transporting products or goods after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit",
                "web_url": "https://www.gov.uk/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit",
                "content_id": "b7b029ef-a1a5-4d87-9e21-3b7409baf77c",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T14:26:08Z",
                "schema_name": "detailed_guide",
                "title": "The professional and business services sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-farming-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-farming-sector-and-preparing-for-eu-exit",
                "content_id": "4cc71bfd-4a2b-4bb0-b3b2-de9a9909ab53",
                "description": "If the UK leaves the EU without a Brexit deal, there may be changes that affect your arable, livestock or horticulture farming business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-04-10T15:36:31Z",
                "schema_name": "detailed_guide",
                "title": "The farming sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-farming-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-farming-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit",
                "content_id": "7567f8d9-ac09-47ed-aa89-cd51e56d72b1",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:00:13Z",
                "schema_name": "detailed_guide",
                "title": "The electronics, machinery and parts sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-electricity-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-electricity-sector-and-preparing-for-eu-exit",
                "content_id": "f0dcee7c-97f2-47da-9727-1f4fb1bf0578",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-12T16:20:00Z",
                "schema_name": "detailed_guide",
                "title": "The electricity sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-electricity-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-electricity-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-space-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-space-sector-and-preparing-for-eu-exit",
                "content_id": "e5b88fc9-60c5-4747-a9a1-263db349605b",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:03:00Z",
                "schema_name": "detailed_guide",
                "title": "The space sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-space-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-space-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit",
                "content_id": "4645a471-468e-4634-be0c-f63668d57626",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:04:57Z",
                "schema_name": "detailed_guide",
                "title": "The consumer goods sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-life-sciences-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-life-sciences-sector-and-preparing-for-eu-exit",
                "content_id": "9aa99522-bab7-4176-811a-82b104710e3f",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:33:09Z",
                "schema_name": "detailed_guide",
                "title": "The life sciences sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-life-sciences-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-life-sciences-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal",
                "base_path": "/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal",
                "content_id": "0246736f-ef09-4d45-ba2d-cd10dc80b82b",
                "description": "UK position on reciprocity of rights for airlines from EU countries, and the basis on which flights will continue in the event of ‘no deal’.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-07T09:40:00Z",
                "schema_name": "detailed_guide",
                "title": "Air services from the EU to the UK in the event of ‘no deal’",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal",
                "web_url": "https://www.gov.uk/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal"
            },
            {
                "api_path": "/api/content/guidance/the-veterinary-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-veterinary-sector-and-preparing-for-eu-exit",
                "content_id": "5e017fbd-e165-43a1-8a16-57edf9f527b0",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect private, official or abattoir veterinarians.\r\n",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-07T15:21:00Z",
                "schema_name": "detailed_guide",
                "title": "The veterinary sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-veterinary-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-veterinary-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers",
                "base_path": "/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers",
                "content_id": "2c65059a-5f7b-45ab-9e93-f1abbb348f73",
                "description": "A checklist of documents that haulage drivers must carry to pass through customs if the UK leaves the EU without a deal on 31 October 2019. ",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-28T16:37:04Z",
                "schema_name": "detailed_guide",
                "title": "Transport goods out of the UK by road if the UK leaves the EU without a deal: checklist for hauliers",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers",
                "web_url": "https://www.gov.uk/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers"
            },
            {
                "api_path": "/api/content/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit",
                "base_path": "/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit",
                "content_id": "72733171-8230-4d7c-80ef-e6d2884f5b22",
                "description": "Information for employers on right to work checks and the immigration status of EU, EEA and Swiss citizens and their family members working in the UK after Brexit.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-04-01T10:12:00Z",
                "schema_name": "detailed_guide",
                "title": "Employing EU, EEA and Swiss citizens and their family members after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit",
                "web_url": "https://www.gov.uk/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal",
                "base_path": "/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal",
                "content_id": "af2e87de-512c-4576-a2f3-6301c2f0b7d8",
                "description": "You’ll need to follow most of the same rules as traders exporting goods to the rest of the world.\r\n",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-24T00:00:00Z",
                "schema_name": "detailed_guide",
                "title": "Trading and moving goods from the UK to the EU if the UK leaves the EU with no deal",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal",
                "web_url": "https://www.gov.uk/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal"
            },
            {
                "api_path": "/api/content/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal",
                "base_path": "/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal",
                "content_id": "b388239a-9be2-4247-bebf-1ce8b0cf7fff",
                "description": "You’ll need to follow most of the same rules as traders importing goods with the rest of the world.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-24T00:00:00Z",
                "schema_name": "detailed_guide",
                "title": "Trading and moving goods from the EU to the UK if the UK leaves the EU with no deal",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal",
                "web_url": "https://www.gov.uk/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal"
            },
            {
                "api_path": "/api/content/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit",
                "base_path": "/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit",
                "content_id": "22148ea2-f252-45df-bf04-fd44680d4467",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:10:19Z",
                "schema_name": "detailed_guide",
                "title": "Steel and other metal manufacturing and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit",
                "base_path": "/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit",
                "content_id": "9383699c-21ec-4dc2-b7b3-f376ef6dc4ba",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:42:29Z",
                "schema_name": "detailed_guide",
                "title": "Non-metal manufacturing and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit",
                "base_path": "/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit",
                "content_id": "00f4bdf1-837b-46da-a24a-55c0de671780",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business, university, research institute or other research organisation.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-14T12:53:00Z",
                "schema_name": "detailed_guide",
                "title": "The science, research and innovation sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit"
            }
        ],
        "available_translations": [
            {
                "title": "Find EU Exit guidance for your organisation",
                "public_updated_at": "2019-04-15T14:53:37Z",
                "document_type": "finder",
                "schema_name": "finder",
                "base_path": "/find-eu-exit-guidance-business",
                "description": "This is the information that has been published so far for your organisation to prepare for EU exit. You can change what information you get using the checkboxes. Come back to this page regularly or sign up to receive emails when new information is published.",
                "api_path": "/api/content/find-eu-exit-guidance-business",
                "withdrawn": false,
                "content_id": "42ce66de-04f3-4192-bf31-8394538e0734",
                "locale": "en",
                "api_url": "https://www.gov.uk/api/content/find-eu-exit-guidance-business",
                "web_url": "https://www.gov.uk/find-eu-exit-guidance-business",
                "links": {}
            }
        ]
    },
    "description": "This is the information that has been published so far for your organisation to prepare for EU exit. You can change what information you get using the checkboxes. Come back to this page regularly or sign up to receive emails when new information is published.",
    "details": {
        "beta": false,
        "document_noun": "publication",
        "summary": "This is the information that has been published so far for your organisation to prepare for EU exit. You can change what information you get using the checkboxes. Come back to this page regularly or sign up to receive emails when new information is published.",
        "canonical_link": true,
        "sort": [
            {
                "name": "Topic",
                "key": "topic",
                "default": true
            },
            {
                "name": "Most viewed",
                "key": "-popularity"
            },
            {
                "name": "Relevance",
                "key": "-relevance"
            },
            {
                "name": "Most recent",
                "key": "-public_timestamp"
            },
            {
                "name": "A to Z",
                "key": "title"
            }
        ],
        "filter": {
            "appear_in_find_eu_exit_guidance_business_finder": "yes"
        },
        "facets": [
            {
                "allowed_values": [
                    {
                        "label": "Accommodation",
                        "value": "accommodation"
                    },
                    {
                        "label": "Aerospace",
                        "value": "aerospace"
                    },
                    {
                        "label": "Agriculture and forestry (including wholesale)",
                        "value": "agriculture"
                    },
                    {
                        "label": "Air freight and air passenger services",
                        "value": "air-freight-air-passenger-services"
                    },
                    {
                        "label": "Arts, culture and heritage",
                        "value": "arts-culture-heritage"
                    },
                    {
                        "label": "Automotive",
                        "value": "automotive"
                    },
                    {
                        "label": "Auxiliary activities",
                        "value": "auxiliary-activities"
                    },
                    {
                        "label": "Charities",
                        "value": "charities"
                    },
                    {
                        "label": "Chemicals",
                        "value": "chemicals"
                    },
                    {
                        "label": "Clothing and consumer goods",
                        "value": "clothing-consumer-goods"
                    },
                    {
                        "label": "Clothing and consumer goods manufacture",
                        "value": "clothing-consumer-goods-manufacturing"
                    },
                    {
                        "label": "Construction",
                        "value": "construction-contracting"
                    },
                    {
                        "label": "Digital, technology and computer services",
                        "value": "computer-services"
                    },
                    {
                        "label": "Creative industries",
                        "value": "creative-industries"
                    },
                    {
                        "label": "Defence",
                        "value": "defence"
                    },
                    {
                        "label": "Education",
                        "value": "education"
                    },
                    {
                        "label": "Electricity",
                        "value": "electricity"
                    },
                    {
                        "label": "Electronics, parts and machinery",
                        "value": "electronics-parts-machinery"
                    },
                    {
                        "label": "Environmental services",
                        "value": "environmental-services"
                    },
                    {
                        "label": "Financial services",
                        "value": "financial-services"
                    },
                    {
                        "label": "Fisheries (including wholesale)",
                        "value": "fisheries"
                    },
                    {
                        "label": "Food, drink and tobacco (retail and wholesale)",
                        "value": "food-and-drink"
                    },
                    {
                        "label": "Food, drink and tobacco (processing)",
                        "value": "food-drink-tobacco"
                    },
                    {
                        "label": "Furniture manufacture",
                        "value": "furniture-manufacture"
                    },
                    {
                        "label": "Gambling",
                        "value": "gambling"
                    },
                    {
                        "label": "Health and social care services",
                        "value": "health-social-care-services"
                    },
                    {
                        "label": "Installation, servicing and repair",
                        "value": "installation-servicing-repair"
                    },
                    {
                        "label": "Insurance",
                        "value": "insurance"
                    },
                    {
                        "label": "Justice including prisons",
                        "value": "justice-prisons"
                    },
                    {
                        "label": "Marine",
                        "value": "marine"
                    },
                    {
                        "label": "Marine transport",
                        "value": "marine-transport"
                    },
                    {
                        "label": "Media and broadcasting",
                        "value": "broadcasting"
                    },
                    {
                        "label": "Medical technology",
                        "value": "medical-technology"
                    },
                    {
                        "label": "Metals manufacture",
                        "value": "metals-manufacture"
                    },
                    {
                        "label": "Mining",
                        "value": "mining"
                    },
                    {
                        "label": "Motor trade",
                        "value": "motor-trades"
                    },
                    {
                        "label": "Non-metal materials manufacture",
                        "value": "non-metal-materials-manufacture"
                    },
                    {
                        "label": "Nuclear",
                        "value": "nuclear"
                    },
                    {
                        "label": "Oil, gas and coal",
                        "value": "oil-gas-coal"
                    },
                    {
                        "label": "Other advanced manufacturing",
                        "value": "other-advanced-manufacturing"
                    },
                    {
                        "label": "Other energy",
                        "value": "other-energy"
                    },
                    {
                        "label": "Other manufacturing",
                        "value": "other-manufacturing"
                    },
                    {
                        "label": "Personal services",
                        "value": "personal-services"
                    },
                    {
                        "label": "Pharmaceuticals",
                        "value": "pharmaceuticals"
                    },
                    {
                        "label": "Ports and airports",
                        "value": "ports-airports"
                    },
                    {
                        "label": "Postal and courier services",
                        "value": "postal-courier-services"
                    },
                    {
                        "label": "Professional and business services",
                        "value": "professional-and-business-services"
                    },
                    {
                        "label": "Public administration",
                        "value": "public-administration"
                    },
                    {
                        "label": "Rail",
                        "value": "rail"
                    },
                    {
                        "label": "Rail (passengers and freight)",
                        "value": "rail-passenger-freight"
                    },
                    {
                        "label": "Real estate",
                        "value": "real-estate-excl-imputed-rent"
                    },
                    {
                        "label": "Repair of computers and consumer goods",
                        "value": "repair-of-computers-consumer-goods"
                    },
                    {
                        "label": "Research",
                        "value": "research"
                    },
                    {
                        "label": "Restaurants, bars and catering",
                        "value": "restaurants-bars-catering"
                    },
                    {
                        "label": "Retail and wholesale (excluding motor trade, food and drink)",
                        "value": "retail"
                    },
                    {
                        "label": "Road (passengers and freight)",
                        "value": "road-passengers-freight"
                    },
                    {
                        "label": "Space",
                        "value": "space"
                    },
                    {
                        "label": "Sports and recreation",
                        "value": "sports-recreation"
                    },
                    {
                        "label": "Telecoms and information services",
                        "value": "telecoms"
                    },
                    {
                        "label": "Tourism",
                        "value": "tourism"
                    },
                    {
                        "label": "Veterinary",
                        "value": "veterinary"
                    },
                    {
                        "label": "Voluntary and community organisations",
                        "value": "voluntary-community-organisations"
                    },
                    {
                        "label": "Warehouses, services and pipelines",
                        "value": "warehouses-services-pipelines"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "and",
                "key": "sector_business_area",
                "name": "Sector / Organisation Area",
                "preposition": "your organisation is in",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Sell products or goods in the UK",
                        "value": "products-or-goods"
                    },
                    {
                        "label": "Buy products or goods from abroad",
                        "value": "buying"
                    },
                    {
                        "label": "Sell products or goods abroad",
                        "value": "selling"
                    },
                    {
                        "label": "Do other types of business in the EU",
                        "value": "other-eu"
                    },
                    {
                        "label": "Transport goods abroad",
                        "value": "transporting"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "and",
                "key": "business_activity",
                "name": "Organisation activity",
                "preposition": "you",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "EU citizens",
                        "value": "yes"
                    },
                    {
                        "label": "No EU citizens",
                        "value": "no"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "employ_eu_citizens",
                "name": "Who you employ",
                "short_name": "Employing EU citizens",
                "preposition": "you employ",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Processing personal data from Europe",
                        "value": "processing-personal-data"
                    },
                    {
                        "label": "Using websites or services hosted in Europe",
                        "value": "interacting-with-eea-website"
                    },
                    {
                        "label": "Providing digital services available to Europe",
                        "value": "digital-service-provider"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "personal_data",
                "name": "Personal data",
                "preposition": "you exchange personal data by",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Copyright",
                        "value": "copyright"
                    },
                    {
                        "label": "Trade marks",
                        "value": "trademarks"
                    },
                    {
                        "label": "Designs",
                        "value": "designs"
                    },
                    {
                        "label": "Patents",
                        "value": "patents"
                    },
                    {
                        "label": "Exhaustion of rights",
                        "value": "exhaustion-of-rights"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "intellectual_property",
                "name": "Intellectual property",
                "preposition": "you use or rely on",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "EU funding",
                        "value": "receiving-eu-funding"
                    },
                    {
                        "label": "UK government funding",
                        "value": "receiving-uk-government-funding"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "eu_uk_government_funding",
                "name": "EU or UK government funding",
                "short_name": "EU or UK government funding",
                "preposition": "you get",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Civil government contracts",
                        "value": "civil-government-contracts"
                    },
                    {
                        "label": "Defence contracts",
                        "value": "defence-contracts"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "public_sector_procurement",
                "name": "Public sector procurement",
                "preposition": "you apply for",
                "type": "text"
            }
        ]
    }
}# Create a test user for GDS-SSO
User.find_or_create_by!(name: "Test User")

a = ContentItem.new
b = {
    "analytics_identifier": "null",
    "base_path": "/find-eu-exit-guidance-business",
    "content_id": "42ce66de-04f3-4192-bf31-8394538e0734",
    "document_type": "finder",
    "first_published_at": "2018-12-19T14:33:59.000+00:00",
    "locale": "en",
    "phase": "live",
    "public_updated_at": "2019-04-15T14:53:37.000+00:00",
    "publishing_app": "rummager",
    "publishing_scheduled_at": "null",
    "rendering_app": "finder-frontend",
    "scheduled_publishing_delay_seconds": "null",
    "schema_name": "finder",
    "title": "Find EU Exit guidance for your organisation",
    "updated_at": "2019-04-15T19:05:55.472Z",
    "withdrawn_notice": {},
    "publishing_request_id": "868-1555340018.918-10.3.3.1-390",
    "links": {
        "email_alert_signup": [
            {
                "api_path": "/api/content/find-eu-exit-guidance-business/email-signup",
                "base_path": "/find-eu-exit-guidance-business/email-signup",
                "content_id": "2818d67a-029a-4899-a438-a543d5c6a20d",
                "description": "You'll get an email each time EU Exit guidance is published.",
                "document_type": "finder_email_signup",
                "locale": "en",
                "public_updated_at": "2019-04-15T14:53:37Z",
                "schema_name": "finder_email_signup",
                "title": "Find EU Exit guidance for your organisation",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/find-eu-exit-guidance-business/email-signup",
                "web_url": "https://www.gov.uk/find-eu-exit-guidance-business/email-signup"
            }
        ],
        "ordered_related_items": [
            {
                "api_path": "/api/content/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit",
                "content_id": "705ff357-7e3a-49ae-823e-5d6c7078d350",
                "description": "If the UK leaves the EU without a Brexit deal, there will be changes that affect your food and drink business. Find out how you can prepare.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-04-10T15:37:16Z",
                "schema_name": "detailed_guide",
                "title": "The food and drink sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-food-and-drink-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/european-and-domestic-funding-after-brexit",
                "base_path": "/guidance/european-and-domestic-funding-after-brexit",
                "content_id": "e9bf1cbb-fcba-485a-8e1b-bf36d195c7b1",
                "description": "When the UK leaves the EU there may be changes to how UK organisations, such as charities, businesses and universities are funded.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:47:00Z",
                "schema_name": "detailed_guide",
                "title": "European and domestic funding after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/european-and-domestic-funding-after-brexit",
                "web_url": "https://www.gov.uk/guidance/european-and-domestic-funding-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/regulations-and-standards-after-brexit",
                "base_path": "/guidance/regulations-and-standards-after-brexit",
                "content_id": "f026b0f9-ce9c-499a-a3cd-1ba9aad8f368",
                "description": "When the UK leaves the EU there may be changes to the requirements for placing certain products on the UK and EU markets.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Regulations and standards after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/regulations-and-standards-after-brexit",
                "web_url": "https://www.gov.uk/guidance/regulations-and-standards-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/intellectual-property-after-brexit",
                "base_path": "/guidance/intellectual-property-after-brexit",
                "content_id": "b0a8b221-b2cb-434c-abb8-1a7323fd1e05",
                "description": "Parts of UK intellectual property (IP) law will change when the UK leaves the EU.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Intellectual property after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/intellectual-property-after-brexit",
                "web_url": "https://www.gov.uk/guidance/intellectual-property-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/the-chemicals-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-chemicals-sector-and-preparing-for-eu-exit",
                "content_id": "d2c7d17e-adf5-4ea1-b16b-4db9f922190a",
                "description": "If the UK leaves the EU without a deal, and you are a company that makes, supplies or uses chemicals, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:34:44Z",
                "schema_name": "detailed_guide",
                "title": "The chemicals sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-chemicals-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-chemicals-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/oil-and-gas-production-and-preparing-for-eu-exit",
                "base_path": "/guidance/oil-and-gas-production-and-preparing-for-eu-exit",
                "content_id": "a5d2f87c-06ae-4cf0-bea7-3fc9746eddd9",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T18:44:00Z",
                "schema_name": "detailed_guide",
                "title": "Oil and gas production and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/oil-and-gas-production-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/oil-and-gas-production-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-aerospace-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-aerospace-sector-and-preparing-for-eu-exit",
                "content_id": "fae745d3-c5a5-4505-aa59-d257e4e938c1",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:58:18Z",
                "schema_name": "detailed_guide",
                "title": "The aerospace sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-aerospace-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-aerospace-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-construction-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-construction-sector-and-preparing-for-eu-exit",
                "content_id": "27952a1b-702d-4166-bd62-6538892f73c3",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:28:28Z",
                "schema_name": "detailed_guide",
                "title": "The construction sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-construction-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-construction-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-automotive-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-automotive-sector-and-preparing-for-eu-exit",
                "content_id": "88ad2f6e-fb1e-47c9-8201-fdb02f90542c",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:56:04Z",
                "schema_name": "detailed_guide",
                "title": "The automotive sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-automotive-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-automotive-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/operating-in-the-eu-after-brexit",
                "base_path": "/guidance/operating-in-the-eu-after-brexit",
                "content_id": "7dd1f3ec-04a9-4954-b7c1-b7fd531daafc",
                "description": "When the UK leaves the EU, the way businesses both offer services in the EU and operate will change. ",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Operating in the EU after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/operating-in-the-eu-after-brexit",
                "web_url": "https://www.gov.uk/guidance/operating-in-the-eu-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/public-sector-procurement-after-brexit",
                "base_path": "/guidance/public-sector-procurement-after-brexit",
                "content_id": "b1194956-d0dd-4353-a835-5c4650528e74",
                "description": "When the UK leaves the EU, there may be changes to how you sell goods or services to the UK public sector.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-01T17:46:00Z",
                "schema_name": "detailed_guide",
                "title": "Public sector procurement after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/public-sector-procurement-after-brexit",
                "web_url": "https://www.gov.uk/guidance/public-sector-procurement-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/the-retail-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-retail-sector-and-preparing-for-eu-exit",
                "content_id": "f896235a-0cf0-4047-af75-926df45e1aa6",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:50:08Z",
                "schema_name": "detailed_guide",
                "title": "The retail sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-retail-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-retail-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/gas-markets-and-preparing-for-eu-exit",
                "base_path": "/guidance/gas-markets-and-preparing-for-eu-exit",
                "content_id": "1ecf3661-4bf0-4776-9cd6-7ecd5cffac2e",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-12T16:18:00Z",
                "schema_name": "detailed_guide",
                "title": "Gas markets and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/gas-markets-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/gas-markets-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/using-personal-data-after-brexit",
                "base_path": "/guidance/using-personal-data-after-brexit",
                "content_id": "2f6219da-6453-494f-bd5e-2e599642612d",
                "description": "When the UK leaves the EU there may be changes to the rules governing the use of personal data.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-06T15:10:00Z",
                "schema_name": "detailed_guide",
                "title": "Using personal data after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/using-personal-data-after-brexit",
                "web_url": "https://www.gov.uk/guidance/using-personal-data-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/energy-and-climate-after-brexit",
                "base_path": "/guidance/energy-and-climate-after-brexit",
                "content_id": "54b2b1e7-68a1-4df9-a9e4-70bcd0bcde71",
                "description": "When the UK leaves the EU there may be changes to areas including energy renewables, the nuclear industry and regulated carbon emissions.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-06T15:10:00Z",
                "schema_name": "detailed_guide",
                "title": "Energy and climate after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/energy-and-climate-after-brexit",
                "web_url": "https://www.gov.uk/guidance/energy-and-climate-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit",
                "base_path": "/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit",
                "content_id": "aff1b568-e23b-464b-bd24-5c0a0cd9bf27",
                "description": "When the UK leaves the EU there may be changes to UK-EU trade at the UK border including on customs, tariffs, VAT, safety and security, documentation, vehicle standards, and controlled products.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-22T16:04:52Z",
                "schema_name": "detailed_guide",
                "title": "Importing, exporting and transporting products or goods after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit",
                "web_url": "https://www.gov.uk/guidance/importing-exporting-and-transporting-products-or-goods-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit",
                "content_id": "b7b029ef-a1a5-4d87-9e21-3b7409baf77c",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T14:26:08Z",
                "schema_name": "detailed_guide",
                "title": "The professional and business services sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-professional-and-business-services-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-farming-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-farming-sector-and-preparing-for-eu-exit",
                "content_id": "4cc71bfd-4a2b-4bb0-b3b2-de9a9909ab53",
                "description": "If the UK leaves the EU without a Brexit deal, there may be changes that affect your arable, livestock or horticulture farming business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-04-10T15:36:31Z",
                "schema_name": "detailed_guide",
                "title": "The farming sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-farming-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-farming-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit",
                "content_id": "7567f8d9-ac09-47ed-aa89-cd51e56d72b1",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:00:13Z",
                "schema_name": "detailed_guide",
                "title": "The electronics, machinery and parts sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-electronics-machinery-and-parts-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-electricity-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-electricity-sector-and-preparing-for-eu-exit",
                "content_id": "f0dcee7c-97f2-47da-9727-1f4fb1bf0578",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-12T16:20:00Z",
                "schema_name": "detailed_guide",
                "title": "The electricity sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-electricity-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-electricity-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-space-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-space-sector-and-preparing-for-eu-exit",
                "content_id": "e5b88fc9-60c5-4747-a9a1-263db349605b",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:03:00Z",
                "schema_name": "detailed_guide",
                "title": "The space sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-space-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-space-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit",
                "content_id": "4645a471-468e-4634-be0c-f63668d57626",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:04:57Z",
                "schema_name": "detailed_guide",
                "title": "The consumer goods sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-consumer-goods-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-life-sciences-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-life-sciences-sector-and-preparing-for-eu-exit",
                "content_id": "9aa99522-bab7-4176-811a-82b104710e3f",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:33:09Z",
                "schema_name": "detailed_guide",
                "title": "The life sciences sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-life-sciences-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-life-sciences-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal",
                "base_path": "/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal",
                "content_id": "0246736f-ef09-4d45-ba2d-cd10dc80b82b",
                "description": "UK position on reciprocity of rights for airlines from EU countries, and the basis on which flights will continue in the event of ‘no deal’.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-07T09:40:00Z",
                "schema_name": "detailed_guide",
                "title": "Air services from the EU to the UK in the event of ‘no deal’",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal",
                "web_url": "https://www.gov.uk/guidance/air-services-from-the-eu-to-the-uk-in-the-event-of-no-deal"
            },
            {
                "api_path": "/api/content/guidance/the-veterinary-sector-and-preparing-for-eu-exit",
                "base_path": "/guidance/the-veterinary-sector-and-preparing-for-eu-exit",
                "content_id": "5e017fbd-e165-43a1-8a16-57edf9f527b0",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect private, official or abattoir veterinarians.\r\n",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-07T15:21:00Z",
                "schema_name": "detailed_guide",
                "title": "The veterinary sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-veterinary-sector-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-veterinary-sector-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers",
                "base_path": "/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers",
                "content_id": "2c65059a-5f7b-45ab-9e93-f1abbb348f73",
                "description": "A checklist of documents that haulage drivers must carry to pass through customs if the UK leaves the EU without a deal on 31 October 2019. ",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-28T16:37:04Z",
                "schema_name": "detailed_guide",
                "title": "Transport goods out of the UK by road if the UK leaves the EU without a deal: checklist for hauliers",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers",
                "web_url": "https://www.gov.uk/guidance/transport-goods-out-of-the-uk-by-road-if-the-uk-leaves-the-eu-without-a-deal-checklist-for-hauliers"
            },
            {
                "api_path": "/api/content/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit",
                "base_path": "/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit",
                "content_id": "72733171-8230-4d7c-80ef-e6d2884f5b22",
                "description": "Information for employers on right to work checks and the immigration status of EU, EEA and Swiss citizens and their family members working in the UK after Brexit.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-04-01T10:12:00Z",
                "schema_name": "detailed_guide",
                "title": "Employing EU, EEA and Swiss citizens and their family members after Brexit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit",
                "web_url": "https://www.gov.uk/guidance/employing-eu-eea-and-swiss-citizens-and-their-family-members-after-brexit"
            },
            {
                "api_path": "/api/content/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal",
                "base_path": "/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal",
                "content_id": "af2e87de-512c-4576-a2f3-6301c2f0b7d8",
                "description": "You’ll need to follow most of the same rules as traders exporting goods to the rest of the world.\r\n",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-24T00:00:00Z",
                "schema_name": "detailed_guide",
                "title": "Trading and moving goods from the UK to the EU if the UK leaves the EU with no deal",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal",
                "web_url": "https://www.gov.uk/guidance/trading-and-moving-goods-from-the-uk-to-the-eu-if-the-uk-leaves-the-eu-with-no-deal"
            },
            {
                "api_path": "/api/content/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal",
                "base_path": "/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal",
                "content_id": "b388239a-9be2-4247-bebf-1ce8b0cf7fff",
                "description": "You’ll need to follow most of the same rules as traders importing goods with the rest of the world.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-24T00:00:00Z",
                "schema_name": "detailed_guide",
                "title": "Trading and moving goods from the EU to the UK if the UK leaves the EU with no deal",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal",
                "web_url": "https://www.gov.uk/guidance/trading-and-moving-goods-from-the-eu-to-the-uk-if-the-uk-leaves-the-eu-with-no-deal"
            },
            {
                "api_path": "/api/content/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit",
                "base_path": "/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit",
                "content_id": "22148ea2-f252-45df-bf04-fd44680d4467",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T13:10:19Z",
                "schema_name": "detailed_guide",
                "title": "Steel and other metal manufacturing and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/steel-and-other-metal-manufacturing-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit",
                "base_path": "/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit",
                "content_id": "9383699c-21ec-4dc2-b7b3-f376ef6dc4ba",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-03-14T12:42:29Z",
                "schema_name": "detailed_guide",
                "title": "Non-metal manufacturing and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit",
                "web_url": "https://www.gov.uk/guidance/mining-the-manufacturing-of-non-metals-and-preparing-for-eu-exit"
            },
            {
                "api_path": "/api/content/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit",
                "base_path": "/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit",
                "content_id": "00f4bdf1-837b-46da-a24a-55c0de671780",
                "description": "If the UK leaves the EU without a deal, there may be changes that affect your business, university, research institute or other research organisation.",
                "document_type": "detailed_guide",
                "locale": "en",
                "public_updated_at": "2019-02-14T12:53:00Z",
                "schema_name": "detailed_guide",
                "title": "The science, research and innovation sector and preparing for EU Exit",
                "withdrawn": false,
                "links": {},
                "api_url": "https://www.gov.uk/api/content/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit",
                "web_url": "https://www.gov.uk/guidance/the-science-research-and-innovation-sector-and-preparing-for-a-no-deal-eu-exit"
            }
        ],
        "available_translations": [
            {
                "title": "Find EU Exit guidance for your organisation",
                "public_updated_at": "2019-04-15T14:53:37Z",
                "document_type": "finder",
                "schema_name": "finder",
                "base_path": "/find-eu-exit-guidance-business",
                "description": "This is the information that has been published so far for your organisation to prepare for EU exit. You can change what information you get using the checkboxes. Come back to this page regularly or sign up to receive emails when new information is published.",
                "api_path": "/api/content/find-eu-exit-guidance-business",
                "withdrawn": false,
                "content_id": "42ce66de-04f3-4192-bf31-8394538e0734",
                "locale": "en",
                "api_url": "https://www.gov.uk/api/content/find-eu-exit-guidance-business",
                "web_url": "https://www.gov.uk/find-eu-exit-guidance-business",
                "links": {}
            }
        ]
    },
    "description": "This is the information that has been published so far for your organisation to prepare for EU exit. You can change what information you get using the checkboxes. Come back to this page regularly or sign up to receive emails when new information is published.",
    "details": {
        "beta": false,
        "document_noun": "publication",
        "summary": "This is the information that has been published so far for your organisation to prepare for EU exit. You can change what information you get using the checkboxes. Come back to this page regularly or sign up to receive emails when new information is published.",
        "canonical_link": true,
        "sort": [
            {
                "name": "Topic",
                "key": "topic",
                "default": true
            },
            {
                "name": "Most viewed",
                "key": "-popularity"
            },
            {
                "name": "Relevance",
                "key": "-relevance"
            },
            {
                "name": "Most recent",
                "key": "-public_timestamp"
            },
            {
                "name": "A to Z",
                "key": "title"
            }
        ],
        "filter": {
            "appear_in_find_eu_exit_guidance_business_finder": "yes"
        },
        "facets": [
            {
                "allowed_values": [
                    {
                        "label": "Accommodation",
                        "value": "accommodation"
                    },
                    {
                        "label": "Aerospace",
                        "value": "aerospace"
                    },
                    {
                        "label": "Agriculture and forestry (including wholesale)",
                        "value": "agriculture"
                    },
                    {
                        "label": "Air freight and air passenger services",
                        "value": "air-freight-air-passenger-services"
                    },
                    {
                        "label": "Arts, culture and heritage",
                        "value": "arts-culture-heritage"
                    },
                    {
                        "label": "Automotive",
                        "value": "automotive"
                    },
                    {
                        "label": "Auxiliary activities",
                        "value": "auxiliary-activities"
                    },
                    {
                        "label": "Charities",
                        "value": "charities"
                    },
                    {
                        "label": "Chemicals",
                        "value": "chemicals"
                    },
                    {
                        "label": "Clothing and consumer goods",
                        "value": "clothing-consumer-goods"
                    },
                    {
                        "label": "Clothing and consumer goods manufacture",
                        "value": "clothing-consumer-goods-manufacturing"
                    },
                    {
                        "label": "Construction",
                        "value": "construction-contracting"
                    },
                    {
                        "label": "Digital, technology and computer services",
                        "value": "computer-services"
                    },
                    {
                        "label": "Creative industries",
                        "value": "creative-industries"
                    },
                    {
                        "label": "Defence",
                        "value": "defence"
                    },
                    {
                        "label": "Education",
                        "value": "education"
                    },
                    {
                        "label": "Electricity",
                        "value": "electricity"
                    },
                    {
                        "label": "Electronics, parts and machinery",
                        "value": "electronics-parts-machinery"
                    },
                    {
                        "label": "Environmental services",
                        "value": "environmental-services"
                    },
                    {
                        "label": "Financial services",
                        "value": "financial-services"
                    },
                    {
                        "label": "Fisheries (including wholesale)",
                        "value": "fisheries"
                    },
                    {
                        "label": "Food, drink and tobacco (retail and wholesale)",
                        "value": "food-and-drink"
                    },
                    {
                        "label": "Food, drink and tobacco (processing)",
                        "value": "food-drink-tobacco"
                    },
                    {
                        "label": "Furniture manufacture",
                        "value": "furniture-manufacture"
                    },
                    {
                        "label": "Gambling",
                        "value": "gambling"
                    },
                    {
                        "label": "Health and social care services",
                        "value": "health-social-care-services"
                    },
                    {
                        "label": "Installation, servicing and repair",
                        "value": "installation-servicing-repair"
                    },
                    {
                        "label": "Insurance",
                        "value": "insurance"
                    },
                    {
                        "label": "Justice including prisons",
                        "value": "justice-prisons"
                    },
                    {
                        "label": "Marine",
                        "value": "marine"
                    },
                    {
                        "label": "Marine transport",
                        "value": "marine-transport"
                    },
                    {
                        "label": "Media and broadcasting",
                        "value": "broadcasting"
                    },
                    {
                        "label": "Medical technology",
                        "value": "medical-technology"
                    },
                    {
                        "label": "Metals manufacture",
                        "value": "metals-manufacture"
                    },
                    {
                        "label": "Mining",
                        "value": "mining"
                    },
                    {
                        "label": "Motor trade",
                        "value": "motor-trades"
                    },
                    {
                        "label": "Non-metal materials manufacture",
                        "value": "non-metal-materials-manufacture"
                    },
                    {
                        "label": "Nuclear",
                        "value": "nuclear"
                    },
                    {
                        "label": "Oil, gas and coal",
                        "value": "oil-gas-coal"
                    },
                    {
                        "label": "Other advanced manufacturing",
                        "value": "other-advanced-manufacturing"
                    },
                    {
                        "label": "Other energy",
                        "value": "other-energy"
                    },
                    {
                        "label": "Other manufacturing",
                        "value": "other-manufacturing"
                    },
                    {
                        "label": "Personal services",
                        "value": "personal-services"
                    },
                    {
                        "label": "Pharmaceuticals",
                        "value": "pharmaceuticals"
                    },
                    {
                        "label": "Ports and airports",
                        "value": "ports-airports"
                    },
                    {
                        "label": "Postal and courier services",
                        "value": "postal-courier-services"
                    },
                    {
                        "label": "Professional and business services",
                        "value": "professional-and-business-services"
                    },
                    {
                        "label": "Public administration",
                        "value": "public-administration"
                    },
                    {
                        "label": "Rail",
                        "value": "rail"
                    },
                    {
                        "label": "Rail (passengers and freight)",
                        "value": "rail-passenger-freight"
                    },
                    {
                        "label": "Real estate",
                        "value": "real-estate-excl-imputed-rent"
                    },
                    {
                        "label": "Repair of computers and consumer goods",
                        "value": "repair-of-computers-consumer-goods"
                    },
                    {
                        "label": "Research",
                        "value": "research"
                    },
                    {
                        "label": "Restaurants, bars and catering",
                        "value": "restaurants-bars-catering"
                    },
                    {
                        "label": "Retail and wholesale (excluding motor trade, food and drink)",
                        "value": "retail"
                    },
                    {
                        "label": "Road (passengers and freight)",
                        "value": "road-passengers-freight"
                    },
                    {
                        "label": "Space",
                        "value": "space"
                    },
                    {
                        "label": "Sports and recreation",
                        "value": "sports-recreation"
                    },
                    {
                        "label": "Telecoms and information services",
                        "value": "telecoms"
                    },
                    {
                        "label": "Tourism",
                        "value": "tourism"
                    },
                    {
                        "label": "Veterinary",
                        "value": "veterinary"
                    },
                    {
                        "label": "Voluntary and community organisations",
                        "value": "voluntary-community-organisations"
                    },
                    {
                        "label": "Warehouses, services and pipelines",
                        "value": "warehouses-services-pipelines"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "and",
                "key": "sector_business_area",
                "name": "Sector / Organisation Area",
                "preposition": "your organisation is in",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Sell products or goods in the UK",
                        "value": "products-or-goods"
                    },
                    {
                        "label": "Buy products or goods from abroad",
                        "value": "buying"
                    },
                    {
                        "label": "Sell products or goods abroad",
                        "value": "selling"
                    },
                    {
                        "label": "Do other types of business in the EU",
                        "value": "other-eu"
                    },
                    {
                        "label": "Transport goods abroad",
                        "value": "transporting"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "and",
                "key": "business_activity",
                "name": "Organisation activity",
                "preposition": "you",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "EU citizens",
                        "value": "yes"
                    },
                    {
                        "label": "No EU citizens",
                        "value": "no"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "employ_eu_citizens",
                "name": "Who you employ",
                "short_name": "Employing EU citizens",
                "preposition": "you employ",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Processing personal data from Europe",
                        "value": "processing-personal-data"
                    },
                    {
                        "label": "Using websites or services hosted in Europe",
                        "value": "interacting-with-eea-website"
                    },
                    {
                        "label": "Providing digital services available to Europe",
                        "value": "digital-service-provider"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "personal_data",
                "name": "Personal data",
                "preposition": "you exchange personal data by",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Copyright",
                        "value": "copyright"
                    },
                    {
                        "label": "Trade marks",
                        "value": "trademarks"
                    },
                    {
                        "label": "Designs",
                        "value": "designs"
                    },
                    {
                        "label": "Patents",
                        "value": "patents"
                    },
                    {
                        "label": "Exhaustion of rights",
                        "value": "exhaustion-of-rights"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "intellectual_property",
                "name": "Intellectual property",
                "preposition": "you use or rely on",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "EU funding",
                        "value": "receiving-eu-funding"
                    },
                    {
                        "label": "UK government funding",
                        "value": "receiving-uk-government-funding"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "eu_uk_government_funding",
                "name": "EU or UK government funding",
                "short_name": "EU or UK government funding",
                "preposition": "you get",
                "type": "text"
            },
            {
                "allowed_values": [
                    {
                        "label": "Civil government contracts",
                        "value": "civil-government-contracts"
                    },
                    {
                        "label": "Defence contracts",
                        "value": "defence-contracts"
                    }
                ],
                "display_as_result_metadata": true,
                "filterable": true,
                "combine_mode": "or",
                "key": "public_sector_procurement",
                "name": "Public sector procurement",
                "preposition": "you apply for",
                "type": "text"
            }
        ]
    }
}


a.attributes.each_pair do |k, v|
  a.attributes[k] = b[k.to_sym]
end
a.save


a.attributes.each_pair do |k, v|
  a[k] = b[k]
end
