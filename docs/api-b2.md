# Loomio B2 API

A simple authenticated REST API for programmatic access to Loomio. All endpoints require `api_key` (Rob's personal key). Base URL: `https://www.loomio.com/api/b2`.

## Authentication

Pass `api_key` as a query parameter or top-level JSON body field on every request:

```
GET  /api/b2/groups?api_key=<key>
POST /api/b2/discussions  body: { "api_key": "<key>", "title": "...", ... }
```

The key is looked up against `User.api_key` — it authenticates as that user.

## Endpoints

### Groups

**List my groups**
```
GET /api/b2/groups?api_key=<key>
```
Returns all groups the authenticated user is a member of. Each group includes `id`, `key`, `handle`, `name`, `token`, and other fields from `GroupSerializer`.

**Get a group** (by numeric ID, key/token, or handle)
```
GET /api/b2/groups/<id_or_key_or_handle>?api_key=<key>
```
- Numeric ID: `/api/b2/groups/12345`
- Key/token (from the URL, e.g. `T9ZtzNcD`): `/api/b2/groups/T9ZtzNcD`
- Handle: `/api/b2/groups/loomio-cooperative-workers`

Use this to look up the numeric `id` for a group before creating discussions.

---

### Discussions

**List discussions in a group**
```
GET /api/b2/discussions?api_key=<key>&group_id=<id>
```
Optional `status` param: `open` (default), `closed`, or `all`.

**Get a discussion**
```
GET /api/b2/discussions/<id>?api_key=<key>
```

**Create a discussion**
```
POST /api/b2/discussions
{
  "api_key": "<key>",
  "group_id": 12345,
  "title": "Thread title",
  "description": "Body text in markdown",
  "description_format": "md",
  "private": true
}
```
Key fields:
- `group_id` — numeric group ID (required)
- `title` — thread title (required)
- `description` — body content
- `description_format` — `"md"` for markdown, `"html"` for HTML (default html)
- `private` — `true` to restrict to group members

Returns the created discussion including its `id` and `url`.

**Update a discussion**
```
PATCH /api/b2/discussions/<id>
{ "api_key": "<key>", "title": "New title", "description": "Updated body" }
```

**Delete a discussion**
```
DELETE /api/b2/discussions/<id>?api_key=<key>
```

---

### Comments

**Create a comment**
```
POST /api/b2/comments
{
  "api_key": "<key>",
  "discussion_id": 67890,
  "body": "Comment text",
  "body_format": "md"
}
```

**Update a comment**
```
PATCH /api/b2/comments/<id>
{ "api_key": "<key>", "body": "Updated text" }
```

**Delete a comment**
```
DELETE /api/b2/comments/<id>?api_key=<key>
```

---

### Polls

**List polls in a group**
```
GET /api/b2/polls?api_key=<key>&group_id=<id>
```
Optional `status`: `active` (default), `closed`, `all`.

**Get a poll**
```
GET /api/b2/polls/<id>?api_key=<key>
```

**Create a poll**
```
POST /api/b2/polls
{
  "api_key": "<key>",
  "group_id": 12345,
  "title": "Poll question",
  "poll_type": "proposal",
  "closing_at": "2026-07-15T00:00:00Z"
}
```

---

### Memberships

**List members of a group**
```
GET /api/b2/memberships?api_key=<key>&group_id=<id>
```
Returns memberships including email (admin only).

**Sync group membership** (add/remove by email list)
```
POST /api/b2/memberships
{
  "api_key": "<key>",
  "group_id": 12345,
  "emails": ["alice@example.com", "bob@example.com"],
  "remove_absent": 0
}
```
Pass `remove_absent: 1` to also remove members not in the `emails` list.

---

## Rob's credentials

```
api_key: 0e6947f7720ba843996d53ba78b93b25
Loomio Cooperative - Workers group handle: loomio-cooperative-workers
```

To find the numeric group ID, run:
```bash
curl -s "https://www.loomio.com/api/b2/groups/loomio-cooperative-workers?api_key=0e6947f7720ba843996d53ba78b93b25" \
  | python3 -c "import json,sys; g=json.load(sys.stdin)['groups'][0]; print(g['id'], g['name'])"
```

## Implementation notes

- Controllers live in `app/controllers/api/b2/`
- Routes are in `config/routes.rb` under `namespace :api > namespace :b2`
- Auth: `BaseController#authenticate_api_key!` looks up `User.active.find_by(api_key:)`
- Group lookup uses `ModelLocator` which resolves numeric ID, `key` field, or `handle` — so all three work as the `:id` param
- `permitted_params` strips `api_key`, `format`, `discussion`/`poll`/`id` top-level keys and wraps remaining params under the resource name
