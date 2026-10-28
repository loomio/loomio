# Server API account and membership provisioning

Self-hosted server operators can now create accounts, list groups, invite or synchronise group members, remove individual memberships, and change group administrator or delegate roles through the Server API (`/api/b3`). These operations use `B3_API_KEY` alone, so integrations do not need a second user key or a bot account added to every group.

Bulk membership updates can add people or explicitly replace a group's membership list. Removing a member also revokes their access to subgroups, group threads, and active polls. Invalid requests and failed updates roll back the complete operation. User API (`/api/b2`) keys continue to follow the user's group permissions.

See the [Server API guide](/en/user_manual/integrations/api/server-api) for endpoints, request examples, and invitation behaviour.
