# Reference integrity review — 2026-09-10

The database inspected was the local `loomio_production` copy of loomio.com, initially at migration `20260909000002`. No connection to the live loomio.com database was used. The review inventoried the schema's foreign keys and integer reference columns, checked 30 selected relationships against the copied data, and traced the cleanup and model destruction paths. This is the first constraint rollout, focused on replacing recurring orphan cleanup; it is not a claim that every application invariant is now enforced by PostgreSQL.

## Constraints applied

Migrations `20260910000000` and `20260910000001` were applied to the test database and the local production copy. The copy had 40 validated foreign keys before this change. The migrations add 13 foreign keys and make three columns required. Migration `20260910000002` adds the missing `received_emails.group_id` index concurrently. They contain no data deletion, backfill, or reparenting. Foreign-key/check installation took approximately 0.04 seconds and validation approximately 2.6 seconds on the local copy; these are not live-production timing guarantees.

| Reference | Delete action | Reason |
| --- | --- | --- |
| `groups.parent_id → groups` | NO ACTION | Preserve subgroup hierarchy; destroy subgroups through model callbacks |
| `topics.group_id → groups` | NO ACTION | Prevent content from losing its group or becoming a direct topic |
| `topic_items.topic_id → topics` | NO ACTION | Preserve surviving timeline content until explicitly destroyed or repaired |
| `stances.poll_id → polls` | NO ACTION | Require normal vote dependency destruction |
| `outcomes.poll_id → polls` | NO ACTION | Preserve decisions until explicitly destroyed |
| `topic_readers.topic_id → topics` | CASCADE | Access/read state belongs to the deleted topic |
| `topic_readers.user_id → users` | CASCADE | Access/read state belongs to the deleted account |
| `membership_requests.group_id → groups` | CASCADE | Requests belong to the deleted group |
| `group_surveys.group_id → groups` | CASCADE | Group survey metadata follows group deletion |
| `received_emails.group_id → groups` | CASCADE | Assigned emails follow group deletion; unassigned emails remain valid |
| `webhooks.group_id → groups` | CASCADE | Retired webhook configuration follows group deletion |
| `tags.group_id → groups` | CASCADE | Group tag metadata follows group deletion |
| `taggings.tag_id → tags` | CASCADE | A tagging cannot survive its tag |

`membership_requests.group_id`, `outcomes.poll_id`, and `tags.group_id` are now `NOT NULL`. Existing non-null requirements already cover the other required links. `groups.parent_id`, `topics.group_id`, and `received_emails.group_id` intentionally remain nullable. The copy contains 15,270 direct topics and 851 unassigned received emails.

All selected new references had zero orphans before installation, including 8,665,317 topic readers, 4,467,459 stances, 3,884,697 timeline items, and 496,636 topics. Existing `poll_options.poll_id`, `stance_choices.stance_id`, `tasks_users.task_id/user_id`, and the composite timeline parent foreign key already prevent their corresponding orphan categories.

## Cleanup removed and retained

`CleanupService` no longer scans or deletes the ordinary-reference orphan categories covered by these constraints and existing keys. Missing-parent timeline repair is removed because the composite `(parent_id, topic_id)` foreign key plus non-null `topic_id` already enforces parent existence and topic agreement. Invalid roots still need application repair.

Polymorphic references still need auditing and cleanup: an ordinary foreign key cannot select a target table from a type column. The retained paths cover missing comment parents and timelines, missing polymorphic targets, retired model types, PaperTrail versions, and subscriptions with no owning group. Topics whose polymorphic root is missing are retained whenever timeline items, polls, or discussions survive. Received-email attachment rows and tag translations remain subject to the polymorphic cleanup after database cascades; cascades do not run Rails callbacks or purge blobs.

Inactive-account eligibility and its conservative locking remain. Numerous user references and polymorphic links are still unprotected, so the new keys do not justify removing those guards. Normal `dependent: :destroy` associations remain because callbacks maintain counters, notifications, search records, and other application state. Raw SQL deletion is not a substitute for normal domain destruction.

The historical `StanceChoiceCleanupService` remains under `db/migrate/support` because migration `20260820000001` uses it before its original constraints exist.

## Existing damage requiring a separate repair decision

Counts below describe non-null references to missing parents; no affected rows were modified.

| Reference | Orphans |
| --- | ---: |
| `stance_receipts.poll_id → polls` | 12,177 |
| `discussion_templates.group_id → groups` | 550 |
| `reactions.user_id → users` | 26 |
| `chatbots.group_id → groups` | 9 |
| `poll_templates.group_id → groups` | 9 |
| `omniauth_identities.user_id → users` | 9 |
| `outcomes.poll_option_id → poll_options` | 3 |
| `member_email_aliases.group_id → groups` | 1 |

The remaining checked relationships `demos.group_id`, `login_tokens.user_id`, `bookmarks.user_id`, and `groups.subscription_id` are clean, but need their own lifecycle review before adopting constraints. Template source IDs, historical actor IDs, search projections, credentials, and other unprotected references also remain outside this rollout. Some integer `_id` fields are external identifiers or polymorphic targets, not ordinary foreign keys.

The existing decision is to preserve historical votes exactly as they are. `stance_choices_score_nonnegative` therefore remains `NOT VALID` with 245 historical negative scores, and `anonymous_ballot_choices_score_nonnegative` remains `NOT VALID` with 48. These votes are not pending cleanup or repair; this rollout does not change them or validate those checks.

Cross-poll joins were also checked: zero identified choices, anonymous choices, or existing outcome-option joins point to an option from another poll. Ordinary single-column foreign keys do not enforce same-poll membership. Enforcing it needs a separate composite-key design and review of vote creation, poll movement, exports, and anonymous data separation.

Foreign keys also do not prove that group ancestry is acyclic and limited to two levels, or that a topic's polymorphic root points back to that same topic. The relevant model validations and repair paths remain necessary.

## Security review

The changed access boundaries are group ancestry, topic ownership, and reader ownership. No link is nullified: deleting a group cannot silently expose a private subgroup or convert a group topic into a direct topic. Reader cascades remove references only when their actual user or topic is deleted; they neither reassign a reader nor change roles, revocation, or delivery preferences. Failed raw deletions roll back their attempted cascades. Normal model destruction still runs callbacks.

The shared group, public, and direct-topic fixture matrix verifies that cleanup preserves exact access and email/push recipients, including guests, revoked and inactive records, conflicting preferences, and signed-out access. Group deletion authorization coverage includes ordinary members, guests, coordinators, and instance administrators. Focused poll tests verify that blocked raw deletion preserves stances, choices, outcomes, and access, and that normal identified-poll destruction still succeeds.

Group import restores users, groups, and topics before timeline items, and parent groups before subgroups, so the new references are satisfied throughout its transaction. Export payloads and import ID remapping are unchanged, including fresh anonymous ballot IDs. No anonymous voter-to-ballot link, serializer, event payload, search projection, notification, mailer, backup representation, or session lifecycle is changed. Existing anonymous ballot service and API tests exercise disclosure restrictions, hidden results, direct polls, and permission failures with the new schema. Operators retain the same database/backup visibility; these constraints do not anonymize historical data or change operator permissions. Broader anonymous data-flow or session constraint changes require a separate review before implementation.

## Deployment and rollback

Deploy all three migrations before running the simplified cleanup code. Constraints are installed as `NOT VALID` to enforce new writes immediately; validation runs separately without retaining the stronger installation locks. Required-column checks are validated before the brief `SET NOT NULL` operation. Twelve of the new references already have supporting indexes; the third migration adds the missing received-email index. If validation fails on another database, retain the old cleanup version and investigate the rows; these migrations deliberately do not delete them.

The local-copy command used was:

```sh
DATABASE_URL=postgresql:///loomio_production RAILS_ENV=development PGOPTIONS='-c lock_timeout=5s' bin/rails db:migrate
```

For a live rollout, use the deployment environment's configured connection and a bounded lock timeout. Retry after resolving lock contention. A partial validation run can be retried. Rolling all three migrations back removes the new foreign keys and index and restores the three nullable columns; restore the previous cleanup implementation with that rollback. No application data is deleted by either migration direction.

## Verification

The local copy now has 53 foreign keys, all validated, and all three new required columns are non-nullable. The affected regression run passed 245 tests and 2,027 assertions, covering cleanup, account cleanup, access/delivery preservation, polls, outcomes, comments, topics, group destruction, membership integrity, anonymous ballot APIs, and group archive round-trips. All three migrations were also reversed and reapplied successfully on the test database.

After integrating the latest master, the final full Rails suite passed: 2,281 tests, 14,185 assertions, zero failures, zero errors, and one existing skipped mailer-preview test. The import regression deliberately places a subgroup before its parent in the export file. The dashboard test now expects “Enabled groups” to match the existing controller. New migration and test files pass RuboCop, and `git diff --check` passes.
