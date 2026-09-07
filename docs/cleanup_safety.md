# Cleanup safety and operator notes

Cleanup eligibility is not permission to delete a later version of a record. Lifecycle cleanup rechecks activity and references at deletion time. Missing timeline entries and broken hierarchy links are not, by themselves, proof that content is disposable.

## Preserved records

- Inactive-account cleanup removes accounts after 60 days without activity, using the most recent account-creation, current-sign-in, previous-sign-in, or last-seen timestamp. It retains instance administrators and accounts with durable ownership, content, membership, access, identity, or notification references.
- Orphan cleanup retains comments with a surviving parent, a surviving topic link, or dependent replies. It retains damaged timeline ancestors with children and groups with missing parents. These remain visible in integrity audits; cleanup does not silently reparent a private group or grant access to a different hierarchy.

The guards are deliberately conservative. Audit counts for broken references include records retained for repair and are not predictions of how many rows will be deleted.

## Regression coverage

Cleanup tests reuse the access and volume fixtures for group topics and direct topics. Quiet/normal/loud role names describe email volume; selected roles have opposite push settings and conflicting account, membership and topic preferences. Tests compare exact access and delivery recipient sets before and after cleanup, read-range repair and merge rollback, while retaining revoked and inactive roles. Successful merge tests preserve the existing destination-wins rule for duplicate memberships and readers, including roles, revocation and channel preferences; source-only readers retain their settings when reassigned.

## Running maintenance

Legacy references are not all protected by foreign keys. Destructive lifecycle rechecks use transactional table locks with `NOWAIT`; they skip busy tables rather than wait for existing writers. New writers can wait while an acquired lock is held. Run large cleanup operations during maintenance, with small batches and application writers drained where practical. Re-audit after a run; skipped candidates do not mean cleanup completed.

Use an isolated database copy with application workers stopped for destructive validation. Confirm the actual database connection before running a deletion task. Compare the original and resulting record identities and content, not only counts. Do not use a previously cleaned snapshot as an untouched baseline.

## Existing delayed group-deletion jobs

New `DestroyGroupWorker` jobs carry the exact archive timestamp recorded when deletion was requested. Restoring and subsequently archiving the group invalidates the earlier job. Jobs without this timestamp are skipped and logged; they must not be supplied with the group's current timestamp automatically. Review whether deletion is still intended, then make a fresh deletion request through the normal administrative workflow.

Account-merge duplicate removal, reference migration, credential revocation, and search updates are transactional. Avatar purges, newsletter changes, and email are deferred until commit. Blocklist and email-routing replacements retain the previous table contents if replacement fails. Concurrent group exports use separate temporary paths.

Demo expiry is unchanged while the replacement demo system is being developed. Deployment scripts are outside this change.
