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
- a stance without a reason has no topic item and is silent; stance activity
  reaches subscribers only when the stance is published on the topic;
- topic live update is publication of a topic item, not notification delivery;
- a chatbot subscribed to topic activity is also a topic-item publication;
- a chatbot explicitly selected for a notification is a notification delivery.

Explicit recipients, chatbot IDs, audience snapshots and recipient messages
belong only to `Notification`. They are real notification columns and are not
copied onto topic items or exposed on the timeline item. `TopicItem` has a real
`pinned_title` column and no generic `custom_fields` payload.

`subject` is the notification's single authoritative reference. A notification
initiated by a topic item points directly to that `TopicItem`; resolvers and
renderers reach the Discussion, Comment, Poll, Stance or Outcome through its
`itemable`. A genuinely topicless notification points directly to its domain
record. Notifications do not duplicate this relationship with a second
`topic_item_id`.

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
3. Every notification has one subject: its initiating topic item when one
   exists, otherwise the relevant domain record.
4. Every recipient/channel pair is unique within a notification.
5. In-app read state belongs to the delivery, never the notification.
6. Queue jobs schedule work; notification and delivery rows are the durable
   source of truth.
7. Retrying audience resolution or delivery dispatch is safe at database
   uniqueness boundaries.
8. Loud subscription delivery and topic live updates remain independent of the
   notification ledger.

## Migration sequence

The preparation migrations create `notification_occurrences`,
`notification_deliveries`, and a durable consolidation cursor without changing
the legacy application tables. loomio.com used this schema to warm the target
tables before cutover.

The cutover release supports both prepared and direct upgrades through the
normal `db:migrate` command. No separate task or operator-managed backfill is
required:

1. If target tables are already warmed, the migration resumes from their durable
   notification ID cursor and processes receipts created since the warm pass.
2. If no warm pass ran, the cursor starts at zero and the same migration
   consolidates every legacy receipt automatically.
3. Once legacy writers have stopped, the migration performs a complete low-ID
   repair sweep. This catches a receipt whose sequence ID was allocated before
   the warm cursor passed it but committed afterwards.
4. The migration verifies zero blocked, missing, or extra notification and
   delivery identities and records completion at the current legacy high-water
   mark.
5. Only after that proof succeeds, the cutover transaction:

   - drops the legacy per-user `notifications` receipts table;
   - renames `notification_occurrences` to `notifications`;
   - drops the migration-only `legacy_event_id` mapping;
   - renames `notification_deliveries.notification_occurrence_id` to
     `notification_id`;
   - discards legacy `stance_created` receipts whose stance activity had no
     topic item;
   - deletes only Event rows whose `topic_id` is null;
   - requires `topic_id` on every remaining Event row; and
   - renames `events` to `topic_items` and `eventable` to `itemable`.

Consolidation batches commit independently, so an interrupted direct upgrade can
resume when `db:migrate` is rerun. The table swap is transactional and the
migration is irreversible because consolidated deliveries do not reconstruct
duplicate legacy receipts.

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

The indexed warm pass processed 11,482,622 remaining receipts in about 17
minutes after a three-row smoke batch. The optimized full audit took 197 seconds.
The final table swap, operational Event deletion, and TopicItem rename took 35.8
seconds. A direct upgrade without warmed tables performs the consolidation and
audit during `db:migrate`, so its maintenance window includes that work.

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
- Retry resolver and delivery jobs and verify stable delivery counts.
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
