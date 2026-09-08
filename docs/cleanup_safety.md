# Cleanup safety and operator notes

Cleanup eligibility is not permission to delete a later version of a record. Lifecycle cleanup rechecks activity and references at deletion time. Missing timeline entries and broken hierarchy links are not, by themselves, proof that content is disposable.

## Preserved records

- Inactive-account cleanup removes accounts after 60 days without activity, using the most recent account-creation, current-sign-in, previous-sign-in, or last-seen timestamp. It retains instance administrators and accounts with durable ownership, content, membership, access, identity, or notification references.
- Seeded-content cleanup requires a known historical helper email and a matching legacy title, before the retirement cutoff. The API-account `bot` flag is not historical provenance. Member-authored matching titles are retained. Member activity, edits by unknown actors, and edits or replies to helper-authored comments preserve the affected content, including comments missing their timeline entries.
- Orphan cleanup retains comments with a surviving parent, a surviving topic link, or dependent replies. It retains damaged timeline ancestors with children and groups with missing parents. These remain visible in integrity audits; cleanup does not silently reparent a private group or grant access to a different hierarchy.

The guards are deliberately conservative. Audit counts for broken references include records retained for repair and are not predictions of how many rows will be deleted.

## Regression coverage

Cleanup tests reuse the access and volume fixtures for group topics and direct topics. Quiet/normal/loud role names describe email volume; selected roles have opposite push settings and conflicting account, membership and topic preferences. Tests compare exact access and delivery recipient sets before and after cleanup, read-range repair and merge rollback, while retaining revoked and inactive roles. Successful merge tests preserve the existing destination-wins rule for duplicate memberships and readers, including roles, revocation and channel preferences; source-only readers retain their settings when reassigned.

## Running maintenance

Legacy references are not all protected by foreign keys. Orphan-comment, topic-item and inactive-user cleanup use transactional table locks with `NOWAIT`; they skip busy tables rather than wait for existing writers. New writers can wait while an acquired lock is held. Run large cleanup operations during maintenance, with small batches and application writers drained where practical. Seeded-content cleanup uses batch transactions and eligibility rechecks without explicit table or row locks. Re-audit seeded content after deletion to confirm no eligible records remain.

Use an isolated database copy with application workers stopped for destructive validation. Confirm the actual database connection before running a deletion task. Compare the original and resulting record identities and content, not only counts. Do not use a previously cleaned snapshot as an untouched baseline.

## Existing delayed group-deletion jobs

New `DestroyGroupWorker` jobs carry the exact discard timestamp recorded when deletion was requested. Restoring and subsequently discarding the group invalidates the earlier job. Jobs without this timestamp are skipped and logged; they must not be supplied with the group's current timestamp automatically. Review whether deletion is still intended, then make a fresh deletion request through the normal administrative workflow. Group discard time and actor are retained in PaperTrail until permanent deletion.

Account-merge duplicate removal, reference migration, credential revocation, and search updates are transactional. Avatar purges, newsletter changes, and email are deferred until commit. Blocklist and email-routing replacements retain the previous table contents if replacement fails. Concurrent group exports use separate temporary paths.

Demo expiry is unchanged while the replacement demo system is being developed. Deployment scripts are outside this change.

Inactive orphan-user cleanup processes at most 100 accounts per daily run. Its reference columns are indexed so the eligibility query and the write-locked per-account recheck do not repeatedly scan large tables. A backlog is drained over multiple days instead of creating an unbounded maintenance run.

## Daily empty expired-trial cleanup

`HourlyTaskJob` enqueues `CleanupEmptyTrialsWorker` at midnight UTC each day, enabled by default. It deletes trial organisations whose subscription expired at least 60 days ago and whose entire group tree contains no topics. Root or subgroup discard status does not affect eligibility because expiry and emptiness independently authorize this cleanup. Actual topic rows determine emptiness, including discarded topics and topics in discarded descendants; counter caches are not used. Standalone polls count as topics. Direct topics and user accounts are preserved. Memberships, templates and uploads do not prevent deletion of a topic-free trial.

Billing references, subscriptions shared by root organisations, and descendants with a different subscription exclude the tree. Each tree is rechecked immediately before normal group destruction, without explicit table or row locks. The worker logs its candidate IDs, before/after counts and individual deletion results as JSON lines. Remaining orphan metadata is handled by orphan cleanup. This does not enable warning or scheduled deletion of trials containing topics.

For a read-only inventory, run `bin/rails loomio:audit_empty_expired_trials`. For a manual run, use `AUDIT_PATH=/private/path/empty-trials.jsonl bin/rails loomio:delete_empty_expired_trials`; the audit file must not already exist. Either task accepts an optional positive `LIMIT` of root organisations. Keep audit files private and confirm the database connection before deletion. Seeded topics must be cleaned separately before they can stop counting against eligibility.

The tests reuse the lifecycle group fixture matrix and extend it with trial expiry, billing, shared-subscription and standalone-poll cases. They compare exact surviving group, topic and user IDs after the daily worker runs.

## Daily expired-subscription warnings

`HourlyTaskJob` also enqueues `WarnExpiredSubscriptionGroupsWorker` at midnight UTC. It processes up to 100 undiscarded root groups per day. A group becomes eligible when its trial expired at least 60 days ago or its subscription was cancelled at least 60 days ago. An expired trial that is eligible for immediate topic-free cleanup is excluded from the warning path, so the two daily tasks cannot act on the same group.

Each eligible group is discarded once, its administrators are emailed, and permanent deletion is scheduled for two weeks later using the exact discard timestamp. The email explains why deletion was scheduled, gives tree-wide counts for subgroups, current members, discussions, polls and comments, and directs the recipient to reply if they need access restored before exporting their data. The worker records the full plan, usage counts, warnings, skips and completion totals as JSON lines.

Run `bin/rails loomio:audit_expired_subscription_groups` for a read-only inventory. Set a positive `LIMIT` to inspect the same leading batch the worker would process.
