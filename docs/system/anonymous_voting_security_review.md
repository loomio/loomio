# Anonymous voting security review

## Scope

This review covers the detached anonymous voting implementation and the migration of closed legacy anonymous polls described in `anonymous_voting.md`. Active legacy anonymous polls remain stance-based until they close. Migrated legacy polls retain a marker and notice because activity created under the old format is outside the stronger native detached-voting guarantee.

## Storage boundary

- `AnonymousPollVoter` contains the named electorate and a submitted/not-submitted boolean. It has no ballot identifier, choice, score, or timestamp.
- `AnonymousBallot` uses a random UUID primary key and contains only its poll and `none_of_the_above`.
- `AnonymousBallotChoice` has no primary key, timestamp, user reference, or sequence value.
- The electorate and ballot tables share only `poll_id`, which identifies the poll rather than a voter-to-ballot relationship.
- Database constraints prevent duplicate electorate entries and duplicate options within a ballot.
- Ballots, choices, and voting configuration become immutable after submission.
- `LegacyAnonymousVoteReason` contains only a detached vote reference and normalized plain-text body. It has no timestamps, participant, application-visible ID, or rich-content associations.

## Submission boundary

- The dedicated service authenticates and authorizes the voter, locks the poll and their electorate row, validates choices against the poll, creates the ballot, and marks participation in one transaction.
- Ballot submission, poll closing, and specified-electorate changes serialize on the same poll-row lock. A vote cannot cross the closing boundary, and a voter cannot be added as the first ballot arrives.
- A used electorate row cannot submit again. Concurrent requests by the same voter serialize on the same electorate-row lock.
- The response contains only `recorded: true`.
- Unsupported fields, including reasons and attachments, are rejected. Ballot request parameters are filtered from application logs.
- Submission creates no stance, ballot event, topic item, search document, live update, shared notification, version, reaction, bookmark, task, translation, mention, comment, or chatbot payload.

## Visibility and composition

- Before closing, general poll serialization omits results, option counts, cast/uncast counts, participation percentages, quorum progress, and STV results.
- The current voter receives only their own eligibility and submitted/not-submitted state.
- Named participation verification is coordinator-only and uses only electorate records.
- Direct-topic participant verification is denied. For group polls, only group administrators receive participant email addresses; other poll coordinators receive no email value. Missing historical inviters remain blank, and specified-voter invitations update cached participation counts inside the locked poll transaction.
- The ballot API has no show, index, update, destroy, revoke, redact, or replace route.
- After closing, charts and CSV exports use aggregate option totals. BLT ballot-pattern export is denied.
- JSON group and direct-topic portability archives preserve detached ballots, choices, participant state, and legacy reasons as an operational restore exception. Ballots and the named ledger have no shared identifier or timestamp, ballot UUIDs are randomized independently for each archive, and imports assign another fresh set of UUIDs.
- Ballots are not side-loaded through stance, event, topic, notification, search, thread, group, or chatbot serializers.
- Migrated legacy reasons are available only for closed marked polls through a dedicated endpoint. The response contains plain text, choices, and `none_of_the_above`; it omits vote and reason record IDs, names, timestamps, submission ordering, and invitation metadata. Choice entries use poll-option IDs already present in ordinary poll serialization.
- Legacy reasons are returned in random-UUID order rather than former stance or submission order.

## Notifications and reminders

- Invitations, opening notices, reminders, closing events, and outcomes are poll-level events. No ballot is an eventable object.
- Ballot submission sends no email and creates no notification or event. The acknowledgement exists only in the API response and current client state.
- The existing hourly publisher calculates reminder eligibility from each poll's current deadline. It skips closed polls and polls lasting less than 24 hours, and the poll-level reminder event prevents duplicate sends.
- Reminder recipient selection uses unused electorate rows and carries no ballot data.

## Access boundaries reviewed

- Signed-out and public viewers cannot submit and receive no pre-close results.
- Ordinary members must have an electorate row and may see only their own participation state.
- Eligible voters can submit once; submitted voters cannot retrieve or change their ballot.
- Non-eligible users cannot submit.
- Coordinators can view participation metadata but cannot retrieve ballots before or after closing.
- Group and topic administration does not create a ballot lookup path.
- Instance administration through application permissions does not create a ballot lookup path.
- Group-topic and direct-topic submission paths use the same detached storage boundary.
- Active legacy polls continue through existing stance closing behavior. Closed migrated polls contain no stances and use aggregate-only detached result and export paths.

## Legacy migration boundary

Operational rollout, canary conversion, batch auditing, and removal of stance-specific anonymity code must follow the two-release plan in `anonymous_voting.md`.

- The Rails schema migration creates storage only. It does not convert polls, enqueue conversion jobs, or register recurring migration work.
- Legacy stance conversion can start only through the manually invoked operator task.
- The operator task requires explicit confirmation that a current database backup exists. `DRY_RUN` audits eligible polls without changing them.
- Only closed anonymous stance-based polls are eligible. Polls with a remaining stance participant ID or named stance-event actor fail before conversion.
- Each poll is locked and migrated in its own database transaction. A random vote UUID is assigned in transaction memory; no stance ID or participant value is copied to detached storage.
- Current submitted votes are converted. Undecided, revoked, and superseded stances are excluded. Redacted current votes retain their choices but not their reasons.
- Result verification compares submitted-vote count, option scores and voter counts, none-of-the-above count, calculated results, STV input and output, and preserved-reason count before stance deletion. Any mismatch rolls back the poll.
- Complete receipt sets may populate the named electorate without vote identifiers. Incomplete receipts create no named electorate records, and existing aggregate participation counts are retained.
- Files belonging to preserved reasons are moved to the poll with no vote or author association. Other stance attachments are detached, and blobs are purged only when unreferenced.
- Direct replies are reparented to the poll before stance events are deleted. Stance events, notifications, reactions, bookmarks, tasks, translations, versions, search documents, choices, and stances are removed.
- Before conversion, the operator captures counts of pre-existing dangling stance references. The post-conversion audit fails if any category increases. Independently, each poll transaction verifies zero remaining references to the exact stance and event IDs it deletes before committing.
- Poll announcement events have obsolete stance ID lists removed. Source receipts remain as the historical participation-verification record and contain no vote identifier.
- The poll is marked as migrated legacy anonymous, remains closed, and cannot be presented as a native detached anonymous poll.

## Residual risks

The application-level design does not protect against database, backup, host, process-memory, transaction-log, network-timing, mail-system, or server-log operators. Small electorates and distinctive aggregate patterns can also permit inference. The UI and user documentation must not describe the feature as cryptographically anonymous or protected from infrastructure operators.

## Validation evidence for manual review

On 2026-07-27:

- the cross-boundary anonymous-voting regression suite passed 364 tests and 1,329 assertions; the only skipped case is the pre-existing optional chatbot comparison render;
- the native anonymous-poll browser scenario passed against a fresh Rails test server and production Vue build;
- the legacy browser scenario passed against a production Vue build and verified the legacy-format notice, plain-text reason and choice, and absence of voter-name and avatar elements;
- locale YAML parsed successfully and both legacy-reason strings were present in every supported client locale;
- four representative polls in the local development dataset passed dry-run preconditions and rollback-only conversion: an ordinary count poll, a proposal with two reasons and one attachment, a dot vote, and an STV election with an incomplete receipt ledger;
- the rollback-only conversions produced 149 detached votes and 11 plain-text reasons, passed the full baseline-aware post-conversion audit, and left all four source polls unchanged; and
- the operator baseline capture and unchanged-database audit commands completed successfully.

The rollback-only run does not replace the deployment checklist requirement to restore a current backup into a disposable database and perform persistent canary conversions there. That operational exercise, manual interface inspection, and independent security/code review remain approval gates before production conversion.
