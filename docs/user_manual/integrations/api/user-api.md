# Loomio User API documentation

<!-- seo-description: Use the Loomio User API to create and manage discussions, comments, polls, threads, and group memberships from other software. -->

`/api/b2` is the user-oriented API for integrations with Loomio. It uses the API key of a user account, and every action is performed as that user.

Group operations use the permissions of the API-key user. If the user can access or administer a group in Loomio, the same access applies through this API.

Use the API key from the Loomio user account that will perform the actions. A dedicated bot account is useful when an integration should not be invited to polls or receive notifications.

Send the API key in an `Authorization: Bearer` header. API keys in query strings are rejected because URLs can be recorded by proxies and access logs. Existing write integrations may continue sending the key in the request body while migrating to the header.

The examples use `YOUR_API_KEY`, group ID `123`, and `https://www.loomio.com/`. Replace these with your API key, group ID, and Loomio installation URL.

## Create Discussion

Create a discussion as the API-key user.

`POST /api/b2/discussions`

### Params

| Name | Description |
| --- | --- |
| `group_id` | Group where thread will exist |
| `title` | Title of the thread, required |
| `description` | Context for the thread, optional |
| `description_format` | Either `md` or `html`, optional, default `md` |
| `recipient_audience` | `group` or null. If `group`, the whole group will be notified about the new thread |
| `recipient_user_ids` | Array of user IDs to notify or invite to the thread |
| `recipient_emails` | Array of email addresses of people to invite to the thread |
| `recipient_message` | Message to include in the email invitation |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

## Show Discussion

Fetch a discussion using the discussion ID, an integer, or key, a string.

`GET /api/b2/discussions/:id`

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

## List Discussions

List discussions in a group. The caller must be a member of the group or a global admin.

`GET /api/b2/discussions`

### Params

| Name | Description |
| --- | --- |
| `group_id` | Integer, required. ID of the group to list discussions from |
| `status` | String, optional, default `open`. Values: `open`, `closed`, `all` |
| `limit` | Integer, optional, default 50. Page size |
| `offset` | Integer, optional, default 0. Offset for pagination |

Legacy: `per` and `from` are accepted as aliases for `limit` and `offset` and will continue to work.

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

## List Threads

List the discussion and poll threads visible to the API-key user, ordered by latest activity. A thread ID is its `topic_id`.

`GET /api/b2/threads`

### Params

| Name | Description |
| --- | --- |
| `limit` | Integer, optional, default 50. Page size |
| `offset` | Integer, optional, default 0. Offset for pagination |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

## Read Thread

Read a thread, its ordered event stream, or its complete visible Markdown document.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

### Example

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

The `items` endpoint returns the ordered event stream, including visible comments, polls, votes, and outcomes. The `markdown` endpoint returns the complete visible thread as one Markdown document. Vote reasons are included only when they are visible to the API-key user.

All thread endpoints enforce the same permissions as the Loomio interface. The API key does not grant access to a thread the user cannot normally open.

## Edit Discussion

Edit a discussion as the API-key user. The same permissions apply as in Loomio: the user must be allowed to edit that discussion.

`PATCH /api/b2/discussions/:id`

### Params

| Name | Description |
| --- | --- |
| `title` | Updated title |
| `description` | Updated context |
| `description_format` | Either `md` or `html`, optional, default `md` |
| `recipient_audience` | `group` or null. If `group`, the whole group will be notified about the edit |
| `recipient_user_ids` | Array of user IDs to notify or invite to the thread |
| `recipient_emails` | Array of email addresses of people to invite to the thread |
| `recipient_message` | Message to include in the email invitation |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

## Soft Delete Discussion

Soft delete a discussion as the API-key user. This discards the discussion and keeps the discussion record in place.

`DELETE /api/b2/discussions/:id`

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

## Create Comment

Create a comment in a discussion as the API-key user.

`POST /api/b2/comments`

### Params

| Name | Description |
| --- | --- |
| `discussion_id` | Integer, required. ID of the discussion to comment on |
| `body` | Comment body, required unless an attachment is provided |
| `body_format` | Either `md` or `html`, optional, default `md` |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

## Edit Comment

Edit a comment as the API-key user. The same permissions apply as in Loomio: the user must be allowed to edit that comment.

`PATCH /api/b2/comments/:id`

### Params

| Name | Description |
| --- | --- |
| `body` | Updated comment body |
| `body_format` | Either `md` or `html`, optional, default `md` |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

## Soft Delete Comment

Soft delete a comment as the API-key user. This discards the comment, hides its body, and keeps the comment record in place.

`DELETE /api/b2/comments/:id`

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

## Create Poll

Create a poll as the API-key user.

`POST /api/b2/polls`

### Params

| Name | Description |
| --- | --- |
| `group_id` | Integer, optional, default null. ID of group for poll. If `discussion_id` is passed, `group_id` is ignored |
| `discussion_id` | Integer, optional, default null. ID of discussion thread to add this poll to |
| `title` | String, required. Title of the poll |
| `poll_type` | String, required. Values: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | String, optional. The body text of the poll |
| `details_format` | String, optional, default `md`. Values: `md` or `html` |
| `options` | Array of strings. If `poll_type` is `proposal`, valid values are `agree`, `disagree`, `abstain`, `block`. If `poll_type` is `meeting`, provide ISO 8601 date or datetime strings. For all other poll types, any string is valid |
| `closing_at` | ISO 8601 string or null, default null. Example: `2026-09-01T12:00:00Z`. If null, voting is disabled and poll is considered work in progress |
| `specified_voters_only` | Boolean, optional, default false. If true, only specified people can vote. If false, everyone in the group will be invited to vote |
| `hide_results` | String, optional, default `off`. Values: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Boolean, default false. Display options to voters in random order |
| `anonymous` | Boolean, optional, default false. Hide identities of voters |
| `recipient_audience` | `group` or null, optional, default null. If `group`, the whole group will be notified |
| `notify_on_closing_soon` | String, optional, default `nobody`. Values: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array of user IDs to notify or invite |
| `recipient_emails` | Array of email addresses of people to invite to vote |
| `recipient_message` | Message to include in the email invitation |
| `notify_recipients` | Boolean, default false. If false, add people without sending notifications. If true, everyone invited in this request will get a notification email |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

## Show Poll

Fetch a poll using the poll ID, an integer, or key, a string.

`GET /api/b2/polls/:id`

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

## List Polls

List polls in a group. The caller must be a member of the group or a global admin. The response includes each poll's current outcome, so you can use `status=closed` to list decided proposals.

`GET /api/b2/polls`

### Params

| Name | Description |
| --- | --- |
| `group_id` | Integer, required. ID of the group to list polls from |
| `status` | String, optional, default `active`. Values: `active`, `closed`, `all` |
| `limit` | Integer, optional, default 50. Page size |
| `offset` | Integer, optional, default 0. Offset for pagination |

Legacy: `per` and `from` are accepted as aliases for `limit` and `offset` and will continue to work.

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

## Edit Poll

Edit a poll as the API-key user. The same permissions apply as in Loomio: the user must be allowed to edit that poll.

`PATCH /api/b2/polls/:id`

### Params

| Name | Description |
| --- | --- |
| `title` | Updated title |
| `details` | Updated poll details |
| `details_format` | Either `md` or `html`, optional, default `md` |
| `options` | Updated option names. Changing options may affect existing votes depending on poll state |
| `closing_at` | ISO 8601 string or null |
| `recipient_audience` | `group` or null. If `group`, the whole group will be notified |
| `recipient_user_ids` | Array of user IDs to notify or invite |
| `recipient_emails` | Array of email addresses of people to invite to vote |
| `recipient_message` | Message to include in the email invitation |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

## Soft Delete Poll

Soft delete a poll as the API-key user. This discards the poll and keeps the poll record in place.

`DELETE /api/b2/polls/:id`

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

## List Memberships

List the members of a group visible to the API-key user.

`GET /api/b2/memberships`

### Params

| Name | Description |
| --- | --- |
| `group_id` | Integer, required. ID of the group whose memberships will be listed |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

## Manage Memberships

Send a list of emails. It will invite all the new email addresses to the group.

`POST /api/b2/memberships`

### Params

| Name | Description |
| --- | --- |
| `group_id` | Integer, required. ID of the group whose memberships will be managed |
| `emails` | Array of strings, required. Email addresses of people to invite into the group |
| `remove_absent` | Boolean. If true, remove anyone from the group whose email is not present in the list |

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

If you pass `remove_absent=1`, any members of the group who were not included in the list will be removed from the group. Be careful, you could remove everyone in your group.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

This returns an object with `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
