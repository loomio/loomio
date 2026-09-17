# Loomio API

Use the Loomio API to connect Loomio with other software and automated workflows.

## User API

The [User API](/en/user_manual/integrations/api/user-api) performs actions as a Loomio user. It can list groups and create or manage threads, comments, polls, and group memberships according to that user's permissions.

For push-based integrations, [group webhooks](/en/user_manual/integrations/api/user-api#webhooks) send selected Loomio events to a web endpoint as JSON. Use the REST endpoints to read or change Loomio data and a webhook when an integration should receive events without polling.

## Server API

The [Server API](/en/user_manual/integrations/api/server-api) lets operators of self-hosted Loomio installations manage user accounts. It is authenticated with a server-wide secret.
