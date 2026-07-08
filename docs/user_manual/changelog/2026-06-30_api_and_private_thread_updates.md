# API and private thread updates

Several changes improved API coverage and private thread behavior.

## B2 API additions

The B2 API now includes more complete discussion and poll operations.

API clients can work with:

- discussions
- polls
- comments
- group records

Comment support includes editing and soft deletion.

User API behavior was also clarified by separating redaction and deletion paths.

## Group endpoint

A groups endpoint was added to the B2 API, making it easier for integrations to discover or work with group records.

## User admin flag in the B3 API

The B3 API now exposes whether a user is an admin where that information is needed by clients.

## Private thread invitees

Invitees on private threads are no longer automatically granted admin access.

This keeps private-thread permissions narrower: being invited into a private thread does not imply permission to administer it.
