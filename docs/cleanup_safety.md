# Cleanup safety and operator notes

Cleanup eligibility is not permission to delete a later version of a record. Lifecycle cleanup rechecks activity and references at deletion time. Missing timeline entries and broken hierarchy links are not, by themselves, proof that content is disposable.

## Preserved records

- Inactive-account cleanup uses the most recent account-creation, current-sign-in, previous-sign-in, or last-seen timestamp. It retains instance administrators and accounts with durable ownership, content, membership, access, identity, or notification references.
- Seeded-content cleanup requires a known historical helper email and a matching legacy title, before the retirement cutoff. The API-account `bot` flag is not historical provenance. Member-authored matching titles are retained. Member activity, edits by unknown actors, and edits or replies to helper-authored comments preserve the affected content, including comments missing their timeline entries.
- Empty-group cleanup schedules a dedicated eligibility recheck without archiving the group. The worker checks the selected root's entire subtree and preserves configured groups and historical activity.
- Orphan cleanup retains comments with a surviving parent, a surviving topic link, or dependent replies. It retains damaged timeline ancestors with children and groups with missing parents. These remain visible in integrity audits; cleanup does not silently reparent a private group or grant access to a different hierarchy.

The guards are deliberately conservative. Audit counts for broken references include records retained for repair and are not predictions of how many rows will be deleted.

## Running maintenance

Legacy references are not all protected by foreign keys. Destructive lifecycle rechecks use transactional table locks with `NOWAIT`; they skip busy tables rather than wait for existing writers. New writers can wait while an acquired lock is held. Run large cleanup operations during maintenance, with small batches and application writers drained where practical. Do not run multiple seeded-cleanup shards concurrently: the safety locks serialize their work, and a busy shard may skip candidates. Re-audit after a run; skipped candidates do not mean cleanup completed.

Use an isolated database copy with application workers stopped for destructive validation. Confirm the actual database connection before running a deletion task. Compare the original and resulting record identities and content, not only counts. Do not use a previously cleaned snapshot as an untouched baseline.

## Existing delayed group-deletion jobs

New `DestroyGroupWorker` jobs carry the exact archive timestamp recorded when deletion was requested. Restoring and subsequently archiving the group invalidates the earlier job. Jobs without this timestamp are skipped and logged; they must not be supplied with the group's current timestamp automatically. Review whether deletion is still intended, then make a fresh deletion request through the normal administrative workflow.

## Historical migrations and recovery

The read-range migration now resets only the malformed cache field, preserving access and notification preferences. The document migration retains distinct blobs even when their filenames match. The obsolete poll-lifecycle migration moves children to the valid topic root and repairs/verifies the affected topics in the deletion transaction; failures roll back that phase.

These changes protect future executions of those migrations. They do not rerun migrations already marked applied and cannot reconstruct deleted reader rows, content, or attachment references. Investigate an untouched backup or a newly imported copy before designing a separate recovery operation. Restoring live production data requires its own reviewed plan.

Account-merge duplicate removal, reference migration, credential revocation, and search updates are transactional. Avatar purges, newsletter changes, and email are deferred until commit. Blocklist and email-routing replacements retain the previous table contents if replacement fails. Concurrent group exports use separate temporary paths.

Demo expiry is unchanged while the replacement demo system is being developed. Deployment scripts are outside this change.
