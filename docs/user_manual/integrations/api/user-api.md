# Loomio User API documentation

<!-- seo-description: Use the Loomio User API to create and manage discussions, comments, polls, threads, and group memberships from other software. -->

`/api/b2` is the user-oriented API for integrations with Loomio. It uses the API key of a user account, and every action is performed as that user.

Group operations use the memberships and group permissions of the API-key user. Instance-administrator status does not expand an API key's access to groups or content; use the Server API for instance-level administration.

Use the API key from the Loomio user account that will perform the actions. A dedicated bot account is useful when an integration should not be invited to polls or receive notifications.

Signed-in users can find their API key and group IDs on the [API access page](/profile/api_access).

Send the API key in an `Authorization: Bearer` header. API keys in query strings are rejected because URLs can be recorded by proxies and access logs.

### Authentication change

The API key was previously accepted as an `api_key` URL parameter. Requests using `?api_key=YOUR_API_KEY` no longer work. Use the HTTP `Authorization` header instead:

```text
Authorization: Bearer YOUR_API_KEY
```

The examples use `YOUR_API_KEY`, group ID `123`, and `https://www.loomio.com/`. Replace these with your API key, group ID, and Loomio installation URL.

## Endpoint summary

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | List the API-key user's groups |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Get a visible group |
| `GET` | `/api/b2/reports` | Generate a participation report |
| `GET` | `/api/b2/search` | Search visible discussions, comments, polls, votes, and outcomes |
| `POST` | `/api/b2/discussions` | Create a discussion |
| `GET` | `/api/b2/discussions/:id` | Get a discussion |
| `GET` | `/api/b2/discussions` | List discussions in a group |
| `PATCH` | `/api/b2/discussions/:id` | Edit a discussion |
| `DELETE` | `/api/b2/discussions/:id` | Soft-delete a discussion |
| `GET` | `/api/b2/threads` | List visible discussion and standalone-poll threads |
| `GET` | `/api/b2/threads/:topic_id` | Get a thread |
| `GET` | `/api/b2/threads/:topic_id/items` | Get the ordered items in a thread |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Get a complete thread as Markdown |
| `POST` | `/api/b2/comments` | Create a comment or reply |
| `PATCH` | `/api/b2/comments/:id` | Edit a comment |
| `DELETE` | `/api/b2/comments/:id` | Soft-delete a comment |
| `POST` | `/api/b2/polls` | Create a poll |
| `GET` | `/api/b2/polls/:id` | Get a poll |
| `GET` | `/api/b2/polls` | List polls in a group |
| `PATCH` | `/api/b2/polls/:id` | Edit a poll |
| `DELETE` | `/api/b2/polls/:id` | Soft-delete a poll |
| `GET` | `/api/b2/memberships` | List a group's memberships |
| `POST` | `/api/b2/memberships` | Add members and optionally remove absent members |
| `GET` | `/api/b2/chatbots` | List a group's chat integrations and webhooks |
| `POST` | `/api/b2/chatbots` | Create a chat integration or webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Update a chat integration or webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Delete a chat integration or webhook |
| `POST` | `/api/b2/chatbots/check` | Send a webhook connection test |

## Groups

### List groups

Return the groups in which the API-key user has an active membership.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

The response contains all matching records in a non-paginated `groups` array. It includes parent groups and subgroups, including groups whose subscription is not currently active. Check the `enabled` field when an integration should operate only on enabled groups.

Important group fields include:

| Field | Description |
| --- | --- |
| `id` | Numeric group ID used by other User API endpoints |
| `key` | Stable short key used in Loomio URLs |
| `handle` | Human-readable group handle |
| `name` | Group name |
| `full_name` | Group name including its parent-group context |
| `parent_id` | Numeric parent-group ID for a subgroup, otherwise `null` |
| `enabled` | Whether the group and its subscription are active |
| `memberships_count` | Number of active and pending memberships |
| `accepted_memberships_count` | Number of accepted memberships |
| `pending_memberships_count` | Number of pending invitations |
| `admin_memberships_count` | Number of group administrators |
| `delegates_count` | Number of delegates |
| `discussions_count` | Number of discussions directly in the group |
| `polls_count` | Number of polls directly in the group |
| `subgroups_count` | Number of subgroups |

The response may include additional group settings, related parent-group records and the API user's memberships. Clients should ignore fields they do not use.

### Get a group

Return one group visible to the API-key user.

`GET /api/b2/groups/:id_or_key_or_handle`

The identifier can be the group's numeric ID, key or handle.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

The response contains the group in the `groups` array and uses the same fields as the list endpoint. A request for a group the API-key user cannot access returns a permission error.

## Webhooks

The User API is request-based: an integration calls Loomio when it wants to read or change data. A group webhook provides the push direction. Loomio sends selected group events to your endpoint as they happen, so an integration does not need to poll the REST API for changes.

Webhooks are configured per group and require group-administrator permission. They can be managed through the Loomio interface:

1. Open the group.
2. Open the group menu and select **Chat integrations**.
3. Add the integration matching the payload format your endpoint accepts. For a general-purpose endpoint, use the Mattermost/Markdown format.
4. Enter a name and the destination URL.
5. Select the events that Loomio should send automatically.
6. Save the integration and use **Test connection** to send a test message.

Use an HTTPS destination with an unguessable URL. Loomio requires the destination to resolve to a public address and blocks requests to local or private network addresses.

Agents and other integrations can instead manage webhooks through the Bearer-authenticated chatbot endpoints described below. The resource is named `chatbots` for compatibility with Loomio's chat integrations, but it also represents general outgoing webhooks.

### List webhooks

Return the chat integrations configured for a group. The API-key user must be an administrator of that group. The response includes destination URLs, so it must not be exposed to ordinary group members.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

The response contains a `chatbots` array with these fields:

| Field | Description |
| --- | --- |
| `id` | Integration ID used for updates and deletion |
| `group_id` | Group receiving the events |
| `name` | Administrative name for the integration |
| `kind` | `webhook` for an outgoing webhook or `matrix` for a Matrix integration |
| `webhook_kind` | Payload format: `markdown`, `slack`, `discord`, `microsoft`, or `webex` |
| `server` | Destination URL |
| `event_kinds` | Events sent automatically |
| `notification_only` | Whether messages contain only the notification headline |

### Create a webhook

`POST /api/b2/chatbots`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": ["new_discussion", "new_comment", "poll_created", "outcome_created"],
    "notification_only": false
  }' \
  https://www.loomio.com/api/b2/chatbots
```

The API-key user must be an administrator of `group_id`. The destination is validated as a public URL before it is saved.

### Update a webhook

`PATCH /api/b2/chatbots/:id`

Send any fields that should change. The webhook cannot be transferred to another group by changing `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

### Test a webhook destination

Send a Markdown-compatible test message to a destination before or after saving its configuration.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

### Delete a webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Deleting the configuration stops future deliveries. It does not delete any Loomio group content.

### Event types

A webhook can subscribe to these event types:

| Event | When it is sent |
| --- | --- |
| `new_discussion` | A discussion is started |
| `discussion_edited` | A discussion is edited |
| `new_comment` | A comment is created |
| `poll_created` | A poll is started |
| `poll_edited` | A poll is edited |
| `poll_closing_soon` | A poll is approaching its closing time |
| `poll_expired` | A poll reaches its closing time |
| `poll_closed_by_user` | A person closes a poll manually |
| `poll_reopened` | A poll is reopened |
| `outcome_created` | An outcome is published |
| `outcome_updated` | An outcome is updated |
| `outcome_review_due` | An outcome review becomes due |
| `stance_created` | A vote is cast |
| `stance_updated` | A vote is changed |

The webhook belongs to one group and receives subscribed events from that group. People can also explicitly select the integration when sharing or sending some notifications, even when the corresponding automatic event is not selected.

### HTTP delivery

Loomio sends an asynchronous HTTP `POST` to the configured URL with this header:

```text
Content-Type: application/json; charset=utf-8
```

The request timeout is five seconds. A `2xx` response, including `204 No Content`, is treated as successful. Webhook consumers should respond promptly, process longer work asynchronously, and tolerate duplicate or out-of-order deliveries.

Loomio does not currently add a webhook signature, shared-secret header, event ID, or delivery ID. Treat the full destination URL as a credential, do not expose it publicly, and include an unguessable token in the URL when the receiving service supports one. If a stable machine-readable event schema or signed delivery is required, use the webhook as a change notification and retrieve the current records through the authenticated User API.

### Payload formats

Webhook payloads are presentation-oriented messages intended for chat services. They are not complete serialized Loomio records. Links in the message identify the affected Loomio content; an integration can follow up through the User API when it needs structured current state.

| Integration format | Principal JSON fields |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limited to approximately 1,900 characters |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

For example, the general Markdown format sends a body shaped like:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

The exact message text depends on the event, group locale, notification-only setting, and Loomio version. Consumers should rely on the selected format's documented top-level fields rather than parsing sentence wording.

## Search

Search discussions, comments, polls, votes, and outcomes visible to the API-key user. Results include public content even when the user is not a member of its group; private content remains subject to normal topic visibility.

`GET /api/b2/search`

### Params

| Name | Description |
| --- | --- |
| `query` | Search text. Exact and fuzzy matches are supported |
| `group_id` | Restrict results to one visible group |
| `org_id` | Restrict results to a visible parent group and its visible subgroups. Use `0` for direct discussions |
| `type` | Restrict results to one type: `Discussion`, `Comment`, `Poll`, `Stance`, or `Outcome` |
| `types` | Comma-separated list of result types |
| `tag` | Restrict results to topics with this tag |
| `author_id` | Restrict results to content by one author. Without `query`, returns that author's recent visible activity |
| `order` | Set to `authored_at_desc` to order matching content by authoring time |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

The response contains a `search_results` array. Each result identifies the matched record and its visible context with fields including `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at`, and `tags`. Fields that do not apply to a result are `null`.

## Participation report

Return the same aggregated participation data used by Loomio's Participation report.

`GET /api/b2/reports`

### Params

| Name | Description |
| --- | --- |
| `section` | Report section: `base`, `users`, or `countries`. Use `users` for per-person activity |
| `group_scope` | `custom` or `my`. The legacy `all` value is treated as `my` because User API keys never receive instance-wide access |
| `group_ids` | Comma-separated group IDs when `group_scope=custom`. IDs outside the API user's memberships are ignored |
| `start_month` | First month to include in `YYYY-MM` format; defaults to 12 months ago |
| `end_month` | Last month to include in `YYYY-MM` format; defaults to the current month |
| `interval` | Interval for the `base` section: `day`, `week`, `month`, or `year` |
| `member_type` | Set to `delegate` with `section=users` to return only current delegates |

A person is a delegate when they have an active delegate membership in any selected group. Their counts are aggregated across all selected groups. Delegate rows are returned even when every activity count is zero. Counts cover threads, comments, polls, votes, outcomes, and reactions; they are not voting participation rates. User rows also include identified ballots issued, cast, and missed. Anonymous polls are excluded from all per-person voting counts. `all_votes_cast` is true only when at least one ballot was issued and every issued ballot was cast.

The API applies the same group visibility rules as the in-product report. A user API key cannot expose report data from groups that user cannot access.

### Example

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

The `users` array contains complete activity rows:

```json
{
  "users": [
    {
      "id": 456,
      "name": "Ada Lovelace",
      "country": "NZ",
      "delegate": true,
      "threads": 2,
      "comments": 8,
      "polls": 1,
      "votes": 5,
      "votes_cast": 5,
      "votes_issued": 6,
      "votes_missed": 1,
      "all_votes_cast": false,
      "outcomes": 1,
      "reactions": 4
    }
  ]
}
```

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

List discussions visible to the API-key user in a group. For a publicly visible group, a nonmember can list its public discussions; private discussions remain restricted to users who can read them in Loomio.

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

List polls visible to the API-key user in a group. For a publicly visible group, a nonmember can list its public polls; private polls remain restricted to users who can read them in Loomio. The response includes each visible poll's current outcome, so you can use `status=closed` to list decided proposals.

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

List the memberships visible to the API-key user. Group members can read member names, IDs, titles, and roles. Email addresses are included only for the API-key user's own account or when the API-key user is a group administrator.

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

Send a list of emails. It will invite all the new email addresses to the group. Unlike listing memberships, this operation requires group-administrator permission.

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
