# Loomio agent API gap inventory

This inventory compares B2 with the interfaces available in the web application. It is the delivery checklist for a user-owned AI agent. Every endpoint must apply the authenticated user's existing Loomio abilities and must not reveal anonymous votes or hidden results.

## Foundation

- [x] Authenticate as the API-key owner
- [x] List groups; create/read/update/discard discussions and polls; create/update/discard comments; list/sync group memberships
- [x] List user-visible threads and read ordered thread items (`/api/b2/threads`, `/api/b2/threads/:id/items`)
- [ ] Replace query-string API keys with scoped, revocable bearer tokens and a documented migration path
- [ ] Add pagination, stable cursors, timestamps, and a machine-readable OpenAPI document

## Read and facilitate

- [ ] A complete thread document: root discussion or poll, ordered events, comments, nested replies, reactions, linked polls, outcomes, and visibility metadata
- [ ] Read current poll options, result totals, quorum/decision rules, and visible latest stances with option choices and reasons
- [ ] Explicit `results_visible` and `anonymous` fields so agents never infer hidden or anonymous information
- [ ] Read discussion and poll templates, including process guidance and defaults
- [ ] Read the current user, notification settings, memberships, and group permissions
- [ ] List notifications with event context; mark one, selected, or all as read

## Write

- [ ] Cast, change, uncast, redact, and restore the current user's stance
- [ ] Create, edit, discard, and restore comments; create and remove the current user's reactions
- [ ] Create and update outcomes after normal Loomio outcome authorization; support review date and selected option
- [ ] Create, update, discard, and browse discussion and poll templates
- [ ] Close/reopen polls, invite voters, and send reminders where the current user can do so
- [ ] Add, invite, revoke, promote, demote, and adjust member notification volume with separate endpoints; retain bulk sync only as an explicit administrative operation
- [ ] Update current-user email and notification preferences, with email-change verification handled through the existing account flow

## Agent-safe response design

- Thread IDs are topic IDs and return `topicable_type`, group context, and canonical URL
- Votes return an option-to-stance mapping and reasons only when Loomio would show them to this user
- Objection-oriented poll types expose the option meaning and prompt alongside the reason, allowing an agent to distinguish support, concern, objection, and block
- Mutations return the changed record and a human-reviewable summary; high-impact actions need an explicit confirmation step in the agent skill
