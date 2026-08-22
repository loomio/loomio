# Notification delivery and topic item plan

## Objective

Separate topic timelines from notification delivery. Records which appear in a
topic become `TopicItem` records with a required `topic_id`. Operational work
such as poll expiry creates durable, idempotent notifications directly instead
of creating an `Event` solely to drive delivery.

## Current architecture

- `Topic#items` is an association to `Event`; there is no `TopicItem` model or
  table.
- `events.topic_id` distinguishes timeline rows from notification-only rows.
- `Notification` requires an event and derives its kind, subject and rendering
  context through that event.
- `PublishEventWorker` retries the complete notification pipeline. In-app
  notifications have no database uniqueness constraint, so a retry after a
  partial success can create duplicates.
- Solid Queue is an execution mechanism, not a durable delivery ledger.
  Finished jobs are cleared hourly.

The production-shaped database contains both clear categories and historical
overlap. Timeline-only kinds include `new_comment`, `new_discussion` and
`poll_created`. Large notification-only kinds include `user_mentioned`,
`reaction_created`, `comment_replied_to` and `invitation_accepted`. Historically
mixed kinds include `poll_expired`, `poll_closing_soon`, `discussion_edited` and
stance events. Migration must classify individual rows by `topic_id`, not assume
that every row of a kind has the same role.

The production-shaped database has 11,207,411 notifications. It contains 73,750
duplicate `(user_id, event_id)` groups representing 133,875 additional rows.
`poll_closing_soon` accounts for 121,639 of those rows. This is existing evidence
that queue retry or repeated publication needs a database idempotency boundary.

## Invariants

1. A topic item always has a valid `topic_id`.
2. Root topic items remain unique for `new_discussion` and `poll_created`.
3. A notification contains the kind, subject, actor and translation values
   required to render it without loading an event.
4. Each logical notification has a deterministic deduplication key. The
   database prevents more than one notification for the same user and key.
5. Solid Queue may schedule and retry delivery work, but queue rows are not the
   source of truth for whether a notification was created.
6. Email and live-update work is enqueued only for notifications newly inserted
   by an attempt. Retrying notification creation is safe.
7. Existing event-backed notifications remain readable throughout the staged
   migration.

## Delivery identity

The initial durable delivery record remains `Notification`; a separate
`NotificationDelivery` table is not required merely to remove operational
events. A deterministic key identifies the logical occurrence, for example:

```text
poll_closing_soon:poll_123:2026-08-22T10:00:00Z
```

The database uniqueness boundary is `(user_id, deduplication_key)`, allowing
one logical occurrence to notify many users while making retries idempotent for
each recipient.

A separate channel-delivery table is not required for the behavior-preserving
refactor below. The follow-on delivery project will need durable per-channel
and per-batch state for email, push, provider message IDs and retry history.

## Implementation sequence

### 1. Self-contained notifications

- Add notification kind and polymorphic subject columns.
- Add a deterministic deduplication key.
- Create the partial unique `(user_id, deduplication_key)` index with the new
  columns. It permits historical null keys and begins enforcing identity as
  rows are dual-written or backfilled.
- Normalize historical `(user_id, event_id)` duplicates before backfilling
  event-based keys. Retain the earliest notification, preserve `viewed = true`
  if any duplicate was viewed, and retain the latest `updated_at`.
- Make event-backed creation populate the self-contained fields before starting
  the historical backfill. This dual-write closes the boundary behind the
  backfill while serializers and mailers continue to use the event-backed path.
- Wait until the dual-writing application version is fully deployed and old
  notification writers have drained, then run duplicate normalization again.
  This catches null-key rows created between the first normalization and the
  deployment cutover.
- Backfill event-backed notifications from their events in bounded notification
  ID ranges. Each short transaction writes only rows whose deduplication key is
  null and whose ID is no greater than the starting high-water mark. Populate:
  - `kind` with the effective notification kind currently returned by the
    serializer, including announcement-kind and comment-reply special cases;
  - `subject_type` and `subject_id` from the eventable used to render the
    notification;
  - the existing `actor_id` only when it is missing and the event supplies an
    actor; and
  - `deduplication_key` as `event:<event_id>`.
- Record the high-water notification ID when the backfill begins, process up to
  that ID, then sweep remaining null keys left by any pre-cutover writer. A
  batch is safe to retry because it does not overwrite populated fields and the
  unique index rejects a second `(user_id, deduplication_key)` row.
- Verify after the sweep that event-backed notifications have non-null kind,
  subject and deduplication key values, and that no duplicate `(user_id,
  event_id)` or `(user_id, deduplication_key)` groups remain.
- Keep `event_id` required initially so the existing application remains
  compatible during deployment.

### 2. Idempotent creation boundary

- Centralize notification insertion in one shared service method.
- Insert all recipients with conflict handling against the unique index.
- Return only newly inserted notifications for live updates and email enqueue.
- Move serializers and mailers to the notification's own kind and subject,
  while retaining an event fallback during migration.

### 3. Pilot a notification-only operation

- Convert `outcome_review_due` first because it has one simple recipient path
  and no timeline role.
- Schedule a Solid Queue job containing the subject and occurrence identity.
- Create notifications directly and verify repeated jobs create no duplicate
  records or email work.

### 4. Convert remaining operational delivery

- Convert poll closing-soon and poll-expired delivery.
- Convert mentions, replies, reactions, announcements, membership notices and
  the remaining notification-only kinds in bounded groups.
- Delete notification-only event rows only after their notifications are fully
  self-contained and verified.
- Handle historically mixed kinds per row: retain rows with `topic_id` and
  remove only rows without it.

### 5. Introduce topic items

- Once notification delivery no longer depends on operational events, migrate
  the remaining timeline event rows to `TopicItem`.
- Require `topic_id` and preserve sequence, position, parent and root uniqueness
  invariants.
- Update topic APIs, serializers, search, exports, live updates and integrity
  tools to use `TopicItem`.
- Remove the old event-only compatibility paths after all installations have
  crossed the migration boundary.

### Refactor verification

- Retry each pilot job before and after notification insertion.
- Verify one notification per `(user_id, deduplication_key)`.
- Verify email/live-update enqueue happens only for newly inserted records.
- Verify existing event-backed notifications still render during transition.
- Verify public, private, group and direct topics retain the same visibility.
- Audit counts by both kind and `topic_id` before deleting historical events.
- Run production-shaped migration timing against `loomio_development` before
  deploying each destructive phase.

### Current migration checkpoint

- The additive notification fields and partial unique delivery-key index are in
  place on the branch.
- Historical duplicate normalization retains the earliest event-backed row,
  merges viewed state and the latest update time, and removes later rows in
  bounded event-ID batches.
- Event-backed in-app creation now dual-writes the compatibility fields through
  a conflict-safe shared insertion method. Retries publish realtime updates and
  enqueue overlapping in-app/email delivery only for newly inserted rows.
- Serializers and access checks still retain their event-backed fallback. Email
  recipients without an in-app notification identity continue through the
  existing event path until channel delivery records are introduced.
- The production-scale timing rehearsal is complete. The next migration
  checkpoint is deployment and worker drain, followed by the bounded historical
  field backfill described in phase 1. Use the index-rebuild mode only if the
  deployment can provide a fully quiesced notification maintenance window.

After deploying dual-writing and draining old workers, audit the high-water
backfill without changing data:

```bash
bundle exec rake loomio:backfill_notification_delivery_fields
```

Review the duplicate, missing-key and blocked-row counts. Apply it only after
the audit is clean enough to proceed:

```bash
APPLY=1 bundle exec rake loomio:backfill_notification_delivery_fields
```

For a quiesced maintenance window, stop every process that can create a
notification and run the faster no-index path:

```bash
APPLY=1 REBUILD_INDEX=1 bundle exec rake loomio:backfill_notification_delivery_fields
```

This mode normalizes duplicates while the index is still present, removes the
partial unique index, writes the historical fields, then recreates and validates
the index. The task attempts to recreate the index after an ordinary error or
interrupt. Do not use this mode while web, job or console processes can write
notifications; without the index, concurrent writers could create duplicate
delivery identities and make the unique rebuild fail.

The task captures its high-water notification ID, normalizes duplicates again,
updates short notification-ID batches and fails if any row within the boundary
is not self-contained afterward. Duplicate normalization covers the entire
table so a group cannot straddle the high-water boundary; `HIGH_WATER_ID` bounds
only field updates. `BATCH_SIZE` and `HIGH_WATER_ID` can be set for a timed
rehearsal on a production-shaped database copy.

The 2026-08-22 dry-run audit of `loomio_development` captured notification ID
16,482,028 as its high-water mark and independently confirmed 11,207,411 missing
keys, 73,750 duplicate `(user_id, event_id)` groups, 133,875 removable duplicate
rows and no rows blocked by missing event metadata. The audit did not mutate
data.

An indexed rehearsal was interrupted after updating 6.3 million rows in
1,006.8 seconds (about 6,300 rows per second) so the no-index maintenance path
could be measured from a clean restore. This is a partial timing result, not a
completed backfill benchmark.

The completed no-index rehearsal used the 2026-08-22 production snapshot. It
started with 11,482,468 notifications, normalized 73,752 duplicate groups by
removing 133,877 rows, backfilled all 11,348,591 retained rows, rebuilt the
partial unique index and passed independent completeness, uniqueness and index
validity checks. Total wall time was 1,291.86 seconds (21 minutes 31.86 seconds),
including duplicate normalization and concurrent index creation. That is about
8,785 retained rows per second end to end. The newer snapshot was about 2.5%
larger than the indexed rehearsal snapshot, and the indexed run was incomplete,
so treat the apparent throughput improvement as deployment guidance rather than
a controlled benchmark result. The cold duplicate-normalization scan was a
material part of the maintenance window and should be timed separately in the
deployment rehearsal.

## Follow-on: delivery channels and preferences

Start this work only after the notification and topic-item refactor is complete
and existing notification behavior has been verified. Treat `Notification` as
the durable record of one logical notification for one recipient. Add separate
delivery records so scheduling, batching and provider retries do not change the
notification's identity or create another notification.

### Delivery invariants

1. Push delivery is an additional channel; enabling it does not implicitly
   disable in-app or email delivery.
2. One email or push attempt may cover several notifications, but each included
   notification is claimed durably so a worker retry cannot deliver it twice.
3. User throttling controls when channel work is released. It does not delay
   creation of the in-app notification or weaken notification deduplication.
4. Preference resolution is explicit about user, group and instance defaults.
   A user's saved choice takes precedence over a group invitation default.
5. A daily summary is scoped to one group. It must not combine private content
   or membership information from different groups in one email.
6. Direct-topic and instance-level notifications have an explicit fallback
   policy when no group preference applies.

### Implementation sequence

1. Introduce durable channel-delivery and delivery-batch records with statuses,
   attempt counts, scheduled times, provider identifiers and idempotency keys.
   Define how a batch claims notifications and how failed attempts are safely
   released or retried.
2. Add user delivery schedules and throttle settings. Support immediate email
   and batched email in which several eligible notifications are rendered in a
   single message.
3. Add push subscriptions and push delivery using the same durable attempt and
   retry boundary as email. Keep channel-specific provider data out of
   `Notification`.
4. Make daily-summary email preferences group-specific and generate one summary
   per user and group. Apply the same visibility checks used by the underlying
   notifications when selecting and rendering summary content.
5. Allow authorized group administrators to choose the default email preference
   offered when inviting new users. Snapshot that default when the invitation
   or initial membership preference is created; later administrator changes must
   not overwrite an existing user's explicit choice.
6. Add operator reporting for queued, throttled, delivered and failed channel
   work, including batch membership and retry history.

### Follow-on verification

- Verify immediate and batched email attempts cannot include or send the same
  notification twice, including worker crashes before and after provider calls.
- Verify push and email can both deliver the same logical notification without
  creating duplicate in-app notifications.
- Verify throttle windows, timezone boundaries and preference changes while a
  delivery is queued.
- Verify daily summaries remain separated by group for public, private and
  direct topics, and omit content the recipient can no longer access.
- Verify invitation defaults for new and existing accounts, reinvitations,
  revoked invitations and users who already saved a preference.
- Verify only the intended group administrator roles can change invitation
  defaults and that changing a default does not rewrite member preferences.
