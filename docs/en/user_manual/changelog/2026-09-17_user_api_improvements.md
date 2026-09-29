## User API improvements

The User API now includes group discovery, full-text search, and outgoing webhook management. API-key users can list public discussions and polls in publicly visible groups without joining them, while private groups and topics continue to follow normal membership permissions.

Group members can list member names, IDs, titles, and roles without receiving other members' email addresses. Only group administrators receive other members' email addresses or manage memberships. Instance-administrator status no longer expands a User API key's access to private content, member information, membership management, or participation reports.

Clients can pass `compact=1` to omit bulky related records or use `exclude_types` to select which related record types to omit. Collection endpoints provide an exact pre-pagination `meta.total` where one is defined and omit the field when no meaningful total is available.

Group administrators can list, create, update, test, and delete outgoing webhooks for groups they administer. The API documentation now includes a complete endpoint summary and the webhook event, delivery, payload, and security contracts.
