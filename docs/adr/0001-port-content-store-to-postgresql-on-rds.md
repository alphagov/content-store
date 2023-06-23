# 1. Port Content Store to PostgreSQL on RDS

Date: 2023-05-16

## Status

Accepted

## Context

Content Store currently runs on legacy self-hosted MongoDB 2.6. This version has been end-of-life since 2016, is difficult to support and has long been noted as [tech debt](https://trello.com/b/oPnw6v3r/govuk-tech-debt). Regardless of version, MongoDB has also proven more difficult to work with in code, and is less well understood amongst GOV.UK technical staff than the much more widely-used PostgreSQL. 

## Decision

As discussed in [GOV.UK RFC158](https://github.com/alphagov/govuk-rfcs/blob/main/rfc-158-port-content-store-to-postgresql.md) the Publishing Platform team will port Content Store's datastore to PostgreSQL on Amazon's managed RDS service.

## Consequences

* The overnight environment sync job, which dumps live data to S3 and imports it into integration & staging environments, will need to be changed.
* We have completed tech spikes into [running the Content Store application on PostgreSQL](https://github.com/alphagov/content-store-on-postgresql) and [dual-running both versions](https://github.com/alphagov/govuk-docker/pull/656) behind a [repeating proxy](https://github.com/alphagov/content-store-proxy). 
* We have completed a round of load testing, and established that the PostgreSQL version serves `GET (path)` requests at least as fast as (in fact slightly faster on average than) the Mongo version on the same hardware.
* Retrieving content-items by `content-id`, rather than `base_path`, is significantly faster on the PostgreSQL version (~2ms rather than 20-30s)
* Consumers of the Content Store API should be unaffected. The API will remain as-is.
* Consumers of the database backups will need to need to be changed, to import a PostgreSQL backup rather than a MongoDB backup. We've spoken to Data Services - the main consumers - about our plans, and we can make the transition easier with our plan to dual-run both MongoDB and PostgreSQL versions behind the repeating proxy linked to above for an initial transition period. This will allow updated integrations to be written, tested and deployed before decommissioning MongoDB.
* Dual-running in production for a period of around a month will also allow time for a history of PostgreSQL backups to accumulate before the switchover.
* Moving to RDS should reduce support and maintenance costs by externalising the responsibility for maintaining a highly-available cluster to Amazon, and eliminating the cognitive load associated with supporting MongoDB.
