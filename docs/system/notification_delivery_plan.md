# Notification delivery and topic item plan

## Objective

Give each persisted concept one meaning:

- `TopicItem` is an occurrence on a topic timeline and always has a `topic_id`.
- `Notification` is one logical notification occurrence, independent of its
  audience and channels.
- `NotificationDelivery` is one channel-specific delivery to one recipient and
  owns delivery and read state.

The historical schema used `Event` for both timeline occurrences and
notification operations, while `Notification` meant one user's in-app receipt.
The migration must not rename those legacy rows in place and pretend they have
the new meanings.

## Target model

```text
TopicItem
  topic_id (required)
  kind, itemable, actor, position, parent

Notification
  kind, subject, actor
  recipient_user_ids, recipient_chatbot_ids
  recipient_message, audience_values

NotificationDelivery
  notification_id
  channel: in_app | email | push | chatbot
  recipient: User | Chatbot | future push endpoint
  status, scheduling, attempts, provider state
  viewed_at and recipient-localized translation values
  unique(notification_id, channel, recipient_type, recipient_id)
```

One notification can therefore have many deliveries. Historical duplicate
per-user receipts consolidate into the same in-app delivery identity; they do
not require deleting data from the live legacy table first.

One old event can produce more than one effective notification kind. In
particular, a `user_mentioned` event is rendered as `comment_replied_to` for the
parent author and `user_mentioned` for other recipients. Historical occurrence
identity must therefore include both the old event ID and effective kind.

## Boundaries

Not every publication is a notification:

- loud-volume comment email is a subscription delivery from the comment's
  topic item and does not create a notification;
- topic live update is publication of a topic item, not notification delivery;
- a chatbot subscribed to topic activity is also a topic-item publication;
- a chatbot explicitly selected for a notification is a notification delivery.

Explicit recipients, chatbot IDs, audience snapshots and recipient messages
belong only to `Notification`. They are real notification columns and are not
copied onto topic items or exposed on the timeline item. `TopicItem` has a real
`pinned_title` column and no generic `custom_fields` payload.

Topic-item publication is declared by its `TopicItems::Publish` concerns. Each
concern performs or enqueues its own work after commit; there is no generic
topic-item dispatcher worker or STI-style reload step.

Stances and other domain records are committed independently of notification
resolution. The domain operation, its required topic item and database-derived
state remain one transaction. Notification creation is deliberately small and
durable; background work resolves and delivers its audience.

## Invariants

1. Every topic item has a valid topic.
2. Root topic items remain unique for `new_discussion` and `poll_created`.
3. Every notification has the kind, subject and actor context needed without a
   topic item.
4. Every recipient/channel pair is unique within a notification.
5. In-app read state belongs to the delivery, never the notification.
6. Queue jobs schedule work; notification and delivery rows are the durable
   source of truth.
7. Retrying audience resolution or delivery dispatch is safe at database
   uniqueness boundaries.
8. Loud subscription delivery and topic live updates remain independent of the
   notification ledger.

## Corrected migration sequence

### Release A: additive preparation

This release preserves the existing event-backed application path unchanged.
It does not reinterpret or mutate the legacy `notifications` table.

1. Create `notification_occurrences` with the complete target notification row
   shape plus migration-only `legacy_event_id`.
2. Create `notification_deliveries` referencing
   `notification_occurrences`, including in-app read and localized rendering
   state.
3. Create a small `notification_consolidation_states` table with a durable
   legacy-notification ID cursor and high-water mark.
4. Deploy this schema while the old application continues to create Event rows
   and per-user Notification receipts.
5. Large installations may optionally warm the resumable consolidation in
   bounded notification-ID batches before deploying the cutover:

   ```sh
   bin/rails loomio:consolidate_notifications
   APPLY=1 BATCH_SIZE=250000 bin/rails loomio:consolidate_notifications
   ```

   Each batch:

   - reads legacy notifications joined to their event;
   - derives the recipient's effective kind;
   - inserts one occurrence identified by `(legacy_event_id, kind)`;
   - inserts or merges one delivered in-app delivery per user;
   - preserves the earliest delivery time, any viewed state, and the retained
     recipient translation values; and
   - advances the cursor in the same transaction.

Batching by notification ID is important. A delayed receipt attached to an old
event is still above the cursor and will be caught. The legacy table remains
authoritative throughout this warm-up, so no compatibility reader or dual
writer is required in the final application. This warm-up is an optimization,
not a required upgrade step; the cutover migration runs or resumes the same
bounded consolidation automatically.

### Release B: drain, verify and cut over

1. Put the old application in maintenance mode and drain notification writers.
2. Run the normal application update. The cutover migration automatically
   extends the high-water mark to the current maximum notification ID,
   processes or resumes the catch-up range in bounded transactions, then
   repairs any lower ID that committed after an earlier cursor passed it.
   `./update.sh` requires no separate backfill command.
3. Verify zero blocked, missing or extra notification/delivery identities and a
   completed cursor at the current maximum legacy notification ID. The repair
   sweep records its own completion marker; the cutover refuses to run without
   it, even when an earlier warm pass reached the same high-water mark.
4. Deploy the cutover application and migration:

   - drop the legacy per-user `notifications` receipts table;
   - rename `notification_occurrences` to `notifications`;
   - drop the migration-only `legacy_event_id` mapping;
   - rename `notification_deliveries.notification_occurrence_id` to
     `notification_id`;
   - delete only Event rows whose `topic_id` is null;
   - require `topic_id` on every remaining Event row; and
   - rename `events` to `topic_items` and `eventable` to `itemable`.

The cutover refuses to run unless the completed high-water mark covers every
legacy notification row. It is irreversible because the consolidated delivery
model intentionally does not reconstruct duplicate legacy receipts.

## Production-shaped rehearsal

Rehearsed on the 2026-08-22 production backup restored directly into
`loomio_development` with `pg_restore -j 10`.

Baseline after prerequisite integrity migrations:

- 11,482,625 legacy notification receipts;
- 11,348,748 distinct effective in-app delivery identities;
- 8,138,990 Event rows: 4,160,198 operational and 3,978,792 timeline rows.

Consolidated result:

- 2,560,309 Notifications;
- 11,348,748 in-app NotificationDeliveries;
- zero blocked, missing or extra notification and delivery identities.

The indexed, resumable warm backfill processed 11,482,622 remaining receipts in
about 17 minutes after a three-row smoke batch. The original per-group anti-join
audit was cancelled after five minutes and replaced with deterministic expected
and actual set counts. The optimized full audit took 197 seconds. The final
table swap, operational Event deletion and TopicItem rename took 35.8 seconds.

These timings are development-machine measurements, not production promises.
The warm backfill is designed to run before the maintenance window; only the
final catch-up, verification and roughly 36-second cutover belong in it.

## Notification creation and resolution

All notification kinds use one initiation method. A resolver class per kind
owns subject validation, translation context and recipient rules. The shared
service owns notification creation, delivery insertion and dispatch scheduling.

Audience timing depends on semantics:

- explicit audiences such as mentions, replies, invitations and
  administrator-selected recipients are snapshotted when the notification is
  created;
- broad derived audiences such as closing-soon voters are resolved in the
  background using current membership and preferences.

`deliveries_generated_at` distinguishes an unresolved notification from one
whose resolver legitimately found no recipients. A partial index makes lost
resolution jobs recoverable. Delivery workers claim ledger rows and retry them;
provider-specific idempotency keys should be used where available.

Detached anonymous polls resolve recipients only through `AnonymousPollVoter`.
Notifications, serializers, mailers, exports, live updates and background jobs
must never reintroduce a ballot-to-user link.

## Verification

- For scheduled producers, repeat the same domain occurrence and verify stable
  notification counts; then change its domain timestamp (for example
  `closing_at` or `review_on`) and verify a new notification is created.
- Retry resolver and dispatcher jobs and verify stable delivery counts.
- Repeat explicit user actions and verify they create distinct notifications.
- Verify in-app queries join through delivered `NotificationDelivery` rows and
  read actions can only update the authenticated user's delivery.
- Verify public, private, group and direct topic visibility independently of
  notification possession.
- Verify timeline counts, sequence, position, parent and root uniqueness before
  and after the Event-to-TopicItem rename.
- Verify loud comment email and chatbot topic subscriptions still publish from
  topic items without creating notifications.
- Run focused anonymous-poll privacy regression tests across reminders, expiry,
  serializers, mailers, exports and jobs.

## Next phase: delivery products and preferences

After this refactor ships with existing user-visible behavior unchanged:

1. Add push as a delivery channel with endpoint lifecycle and provider
   idempotency.
2. Add batch email records which claim several email deliveries and render
   them in one message without changing notification identity.
3. Add per-user delivery throttling and scheduling policy.
4. Add daily summary emails per group rather than one cross-group summary.
5. Let group administrators choose default email preferences when inviting new
   users. Store the applied preference explicitly so later administrator
   changes do not silently rewrite an existing member's choice.

Batching and throttling belong above `NotificationDelivery`: they decide when
and with which other deliveries a row is sent, while the delivery ledger keeps
one durable channel/recipient identity for auditing and retry.
