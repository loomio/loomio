<!-- translation-section: introduction -->

# Loomio Server API documentation

<!-- seo-description: Use the Loomio Server API to provision user accounts, discover groups, and manage memberships on a self-hosted Loomio installation. -->

`/api/b3` is for server-level operations. Use `/api/b2` for user-oriented actions performed as a Loomio user account.

Use one server key to create and manage accounts, discover groups across the installation, and manage their memberships and roles. No bot account, user API key, or membership in the groups is required. User API keys continue to follow the user's group permissions.

<!-- translation-section: authentication -->

## Authentication

Set `B3_API_KEY` to a secret longer than 16 characters.

Send the key as a bearer token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Send credentials only in the `Authorization` header. API keys in query strings or request bodies are rejected.

<!-- translation-section: provisioning -->

## Provision accounts and memberships

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/api/b3/users` | Create an account |
| `GET` | `/api/b3/groups` | Discover groups across the installation |
| `GET` | `/api/b3/memberships` | List memberships in a group |
| `POST` | `/api/b3/memberships` | Invite members or synchronise a complete membership list |
| `PATCH` | `/api/b3/memberships/:id` | Change group administrator and delegate roles |
| `DELETE` | `/api/b3/memberships/:id` | Revoke one membership |

Existing account update, deactivation, reactivation, redaction, and deletion endpoints are described below.

### Create an account

`POST /api/b3/users`

Send a `user` object with a required `email`. Email addresses are trimmed and converted to lowercase. Optional fields are `name`, `username`, and `is_admin`. Here `is_admin` means an instance administrator; group administrator roles are managed on memberships. Omit `username` to generate one automatically. Unknown fields are rejected.

```bash
curl https://loomio.example.org/api/b3/users \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "user": {
      "email": "ada@example.org",
      "name": "Ada Lovelace",
      "username": "ada",
      "is_admin": false
    }
  }'
```

The response is HTTP `201` with a `user` object. Invalid fields or an email or username already in use return HTTP `422`. Creating an account does not send an invitation, sign the person in, or mark their email as verified. Invite them to a group using the membership endpoint to send an invitation through the normal notification workflow.

### Discover groups

`GET /api/b3/groups`

List all groups that have not been deleted, including private groups and groups with expired subscriptions. Results are ordered by ascending ID. Use `limit` (default and maximum `50`) and `offset` (default `0`) to page through them.

```bash
curl 'https://loomio.example.org/api/b3/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "groups": [
    {
      "id": 123,
      "key": "examplegroup",
      "name": "Planning group",
      "handle": "planning",
      "parent_id": null,
      "group_privacy": "secret"
    }
  ],
  "meta": {
    "total": 1
  }
}
```

### List memberships

`GET /api/b3/memberships?group_id=123`

`group_id` is required. Results include accepted memberships and pending invitations, ordered by ascending membership ID. Revoked memberships are excluded. Use `limit` (default and maximum `50`) and `offset` (default `0`) for pagination.

```bash
curl 'https://loomio.example.org/api/b3/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "memberships": [
    {
      "id": 456,
      "group_id": 123,
      "user_id": 789,
      "user_email": "ada@example.org",
      "user_name": "Ada Lovelace",
      "admin": false,
      "delegate": false,
      "accepted_at": null,
      "pending": true
    }
  ],
  "meta": {
    "total": 1
  }
}
```

`admin` and `delegate` are group roles. `accepted_at` is the acceptance timestamp, or `null` while an invitation is pending. This endpoint does not expose invitation tokens, login credentials, or votes.

### Invite or synchronise members

`POST /api/b3/memberships`

Send a required `group_id` and `emails` array. By default, this adds the listed people who do not already have an active membership, leaving everyone else in place. Email addresses are trimmed, converted to lowercase, and deduplicated. New addresses create accounts and pending invitations. Existing verified members of another active group in the same organisation are accepted automatically, matching the User API invitation workflow.

```bash
curl https://loomio.example.org/api/b3/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

To synchronise a complete membership list, explicitly set `remove_absent` to `true`. Anyone missing from the list is removed from that group and its subgroups. An empty array with `remove_absent: true` removes everyone, including group administrators. Omit `remove_absent` or set it to `false` when only adding people. The legacy values `1` and `0` are also accepted.

```bash
curl https://loomio.example.org/api/b3/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org"
    ],
    "remove_absent": true
  }'
```

```json
{
  "added_emails": [],
  "removed_emails": [
    "alex@example.org"
  ]
}
```

Repeating the same request does not create duplicate memberships or repeat invitations. Reinviting a revoked member restores their group access without restoring a previous administrator role. New invitations and role changes use the normal notification workflow, with no user recorded as the actor.

Missing or malformed email lists and invalid boolean values return HTTP `400`. A listed deactivated account returns HTTP `422`; reactivate it explicitly before adding it. Invalid account data, subscription limits, or other failures roll back the whole synchronisation, including new accounts and membership removals. Additions require an active group and remain subject to subscription member limits.

### Update membership roles

`PATCH /api/b3/memberships/:id`

Send a `membership` object containing either or both boolean fields `admin` and `delegate`. Omitted roles remain unchanged. Unknown fields are rejected; the endpoint cannot transfer a membership, accept an invitation, or change voting weights.

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

Returns a `membership` object with the same fields as a listed membership. Granting a role creates the usual role notification; repeating an unchanged role does not notify again. Role changes require an active group. Revoked memberships return HTTP `404`.

### Remove one membership

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Returns `{"success": true}`. Removal revokes access in the group and its subgroups, including topic access and voting rights in active polls. It does not delete the account, alter unrelated groups, or remove direct-thread access. Repeating a removal succeeds. You can remove memberships from groups with expired subscriptions; deleted groups return HTTP `404`.

<!-- translation-section: user-object -->

## User Object

User responses use this shape:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
  "is_admin": false,
  "active": true,
  "deactivated_at": null,
  "identities": [
    {
      "id": 456,
      "identity_type": "oauth",
      "uid": "external-123",
      "email": "ada@example.org",
      "name": "Ada Lovelace"
    }
  ]
}
```

<!-- translation-section: list-users -->

## List Users

List all user accounts on the Loomio installation.

`GET /api/b3/users`

<!-- translation-section: example -->

### Example

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Returns:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Show User

Find a user by their Loomio user ID or external identity.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Examples

By Loomio user ID:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

By external identity:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Returns:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Update User

Update the profile fields of a user found by their Loomio user ID or external identity.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Params

| Field | Description |
| --- | --- |
| `name` | Display name |
| `username` | Loomio username |
| `email` | Email address |

<!-- translation-section: examples-2 -->

### Examples

By Loomio user ID:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

By external identity:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Returns the updated user:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Deactivate User

Deactivate a user account found by its Loomio user ID or external identity.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Examples

By Loomio user ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

By external identity:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Returns:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Reactivate User

Reactivate a deactivated user account found by its Loomio user ID or external identity.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Examples

By Loomio user ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

By external identity:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Returns:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Redact User

Redaction keeps the user's comments and other user-generated content within their groups, but removes known personally identifying information such as name, bio, profile photo, email address, login credentials, identities, and active sessions.

This is the recommended way to remove a user from Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Examples

By Loomio user ID:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

By external identity:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Returns:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Delete User

Delete removes the user and records the user created. Comments are removed from threads, votes are removed from polls, and groups, discussions, polls, and other records created by the user may also be deleted through database associations.

This is very destructive. Redaction is highly recommended instead.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Examples

By Loomio user ID:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

By external identity:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Returns:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## SSO Profile Sync Settings

Use these settings when another system manages Loomio profile fields.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` prevents users from editing these fields themselves:

| Field | Notes |
| --- | --- |
| `name` | Managed by external sync |
| `username` | Managed by external sync |
| `email` | Managed by external sync |
| `avatar_kind` / `uploaded_avatar` | Managed by external sync |

Users can still edit Loomio-local fields such as `short_bio` and `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` updates `name` and `email` from SSO login data. Leave it commented out or unset when an external sync script should be the only source of those updates.

`LOOMIO_SSO_FORCE_USER_ATTRS` still works for existing installs. It both disables user edits and updates `name` and `email` on SSO login.
