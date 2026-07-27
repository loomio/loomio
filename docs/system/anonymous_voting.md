# Anonymous voting

## Status

This document specifies the intended design and security guarantees for Loomio's new anonymous voting system. It is the normative reference for implementation, review, testing, user documentation, and interface copy.

The new system initially introduces detached anonymous voting for new polls, then migrates closed legacy anonymous polls according to the migration section in this document. Vote choices and readable reason text are preserved. Obsolete stance records and their rich-content features are removed only after per-poll verification.

The implementation must distinguish between:

- identified polls, which use `Stance`;
- native anonymous polls, which use detached `AnonymousBallot` records; and
- migrated legacy anonymous polls, which use detached ballots plus read-only plain-text legacy reasons.

The exact database field used to identify the voting system is an implementation decision. It must be immutable after voting opens except for the verified, closed-poll legacy migration defined below.

## Purpose

Anonymous voting should be safe primarily because identifying and correlating data is never stored with a ballot, rather than because serializers and controllers repeatedly remove sensitive fields.

After an anonymous ballot has been submitted, its stored representation should be suitable for disclosure after the poll closes without field-by-field anonymization or identifier substitution.

The named electorate record and the ballot must be separate data sets with no stored relationship between them.

## Terminology

### Identified stance

A response to an identified poll. It is represented by `Stance` and may include a participant, reason, revisions, events, reactions, bookmarks, tasks, translations, comments, mentions, and search indexing.

### Legacy anonymous stance

A `Stance` belonging to an anonymous poll created under the previous voting system. Legacy records retain their existing behavior and do not receive the guarantees in this document.

### Anonymous poll voter

A named electorate record for a new anonymous poll. It records eligibility, invitation provenance, group-membership state at invitation, and whether the person submitted a ballot. It contains no ballot identifier or ballot choices.

The proposed model name is `AnonymousPollVoter`.

### Anonymous ballot

A detached response to a new anonymous poll. It contains a random UUID, its poll, and its choices or scores. It contains no participant or electorate reference.

## Security guarantee

For a new anonymous poll, Loomio records whether each eligible person has submitted a vote, but stores the submitted ballot without a user association. Application users, including poll participants, coordinators, group administrators, and instance administrators using the application, cannot link an individual ballot to its voter.

Individual ballots, ballot choices, and calculated results are unavailable through the application until the poll closes.

Loomio does not store a ballot's actual submission time, a participant relationship, invitation metadata, written reason, or a joinable identifier shared with the named electorate ledger.

## Threat model

### Protected against

The design must prevent ballot-to-voter correlation by:

- signed-out or public users;
- ordinary group members;
- invited poll participants;
- poll coordinators;
- group and topic administrators;
- instance administrators using application interfaces;
- API clients using supported application permissions;
- application exports that follow the authorization and export rules in this document; and
- composition of multiple application endpoints, serializers, events, live updates, notifications, searches, and exports.

### Not protected against

The application-level guarantee does not protect against:

- operators with direct database, backup, process-memory, host, or transaction-log access;
- observation of network request timing or server access logs;
- malicious changes to the running application;
- a voter identifying themselves outside Loomio;
- statistical inference from a small electorate;
- inference from a distinctive ballot pattern; or
- information voluntarily shared by voters.

Protecting ballots from operators with infrastructure access requires a separate cryptographic design. That guarantee must not be implied by interface or user-manual copy.

## Data model

### `AnonymousPollVoter`

`AnonymousPollVoter` is the named electorate and participation ledger for a new anonymous poll.

It records only:

- `poll_id`;
- `voter_id`;
- `inviter_id` when applicable;
- whether the voter was a group member when invited; and
- whether a ballot has been submitted.

It must have a unique database constraint on `poll_id` and `voter_id`.

It must not contain:

- an `anonymous_ballot_id`;
- ballot choices or scores;
- a ballot UUID, token, digest, or commitment later exposed with a ballot;
- a precise submission timestamp; or
- any other value that can join it to an anonymous ballot.

The electorate record may contain invitation timing only if a product requirement is established for it. Invitation time must never be copied to a ballot or used to order ballots.

### `AnonymousBallot`

`AnonymousBallot` represents a submitted ballot.

It contains only:

- a UUID primary key generated independently of database insertion order;
- `poll_id`; and
- ballot-level fields required by supported poll types, such as `none_of_the_above`.

It must not contain:

- `participant_id` or another user reference;
- an electorate or receipt reference;
- inviter, revoker, redactor, or membership metadata;
- a written reason;
- attachments;
- actual submission time;
- `created_at` or `updated_at` timestamps;
- version counts or audit versions; or
- a sequence number derived from submission order.

The UUID is the ballot's actual primary key. No separate public identifier, pseudonymous serializer ID, or sequence-backed database ID is required.

### `AnonymousBallotChoice`

`AnonymousBallotChoice` contains:

- `anonymous_ballot_id` as a UUID foreign key;
- `poll_option_id`; and
- the score or value required by the poll type.

It must not contain timestamps or user references.

A unique constraint must prevent duplicate choices for the same ballot and option.

### Identified polls and receipts

New identified polls do not need persisted participation receipts. Their named stances already record electorate, invitation, participant, and cast state.

Identified participation reports should be derived from stances.

Existing `StanceReceipt` records remain available for historical polls. Complete receipt sets may be copied into `AnonymousPollVoter` during legacy migration, but the source receipts are not deleted or linked to individual ballots.

## Poll invariants

For a new anonymous poll, shared model and service boundaries must enforce:

- results are hidden until the poll closes;
- the result-visibility mode cannot be changed from `until_closed`;
- ballots cannot contain reasons or attachments;
- a voter can submit only one ballot;
- a submitted ballot cannot be reviewed through the application before closing;
- a submitted ballot cannot be changed, revoked, or replaced;
- anonymous ballots do not create stance rows;
- anonymous ballots do not create per-ballot events;
- anonymous ballots are not added to a topic or thread;
- anonymous ballots cannot receive comments or replies;
- anonymous ballots cannot receive reactions;
- anonymous ballots cannot be bookmarked;
- anonymous ballots cannot be attached to tasks;
- anonymous ballots cannot be translated;
- anonymous ballots cannot create mentions;
- anonymous ballots are not search indexed;
- anonymous ballots do not create version history;
- anonymous ballots do not produce per-ballot notifications or shared live updates; and
- a closed anonymous poll cannot be reopened.

These rules must be enforced at shared storage and service boundaries. UI hiding and serializer filtering are not sufficient enforcement.

Poll-level discussion remains available where the poll topic permits it. The prohibition applies to content attached to an individual ballot, not to ordinary comments on the poll topic.

## Electorate lifecycle

A new anonymous poll uses `AnonymousPollVoter` rather than undecided stances to represent eligible voters.

When voting opens, Loomio must:

1. establish the eligible electorate;
2. create or finalize one electorate record for each eligible voter;
3. record invitation provenance and group-membership state where required;
4. make the poll eligible for the hourly automatic-reminder check; and
5. avoid creating named or undecided stance records.

The implementation must define whether the electorate is frozen when voting opens and whether late invitations are permitted. The selected policy must not create a ballot-to-voter correlation path.

## Ballot submission

A dedicated service must be the only supported way to submit an anonymous ballot.

The submission path must:

1. authenticate the voter;
2. authorize access to the poll;
3. lock the poll row shared by submission, closing, and electorate changes;
4. lock the voter's `AnonymousPollVoter` record;
5. confirm that voting is open and the electorate record is unused;
6. validate choices against the poll and poll options;
7. create a detached `AnonymousBallot` and its choices without a user association;
8. mark the electorate record as used without storing the ballot UUID;
9. commit the ballot and participation-state change atomically.

The shared poll lock must prevent a submission from crossing the closing boundary or racing the electorate freeze. The electorate-row lock must prevent duplicate or concurrent submissions by the same voter.

The submission response must acknowledge success without returning the ballot UUID or choices. The client must discard its local vote state after a successful submission.

Sensitive submission parameters must not be included in application logs, analytics, metrics, error reports, background-job arguments, or audit events together with voter or electorate identifiers.

The authenticated voter and submitted choices necessarily coexist briefly in application memory and within one database transaction. The infrastructure-level correlation this permits is outside the application-level guarantee.

## Vote immutability

A voter cannot change or withdraw an anonymous ballot after submission.

The application must not provide an update, revoke, redact, or replace operation for an anonymous ballot. Coordinators and administrators must not receive a privileged ballot-editing path.

If an operational need to invalidate ballots is introduced later, it requires a separate security design because identifying a person's ballot is intentionally impossible.

## Time and ordering

Anonymous ballots must not store their actual submission time.

The design must not use `cast_at`, `created_at`, `updated_at`, event timestamps, sequence-backed identifiers, or job timestamps as ballot attributes.

Ballots must not be ordered by submission, insertion, event, receipt, or request time. If individual ballots are returned after closing, the API must use a deterministic order independent of submission timing, such as UUID order.

The system may retain infrastructure timestamps outside the ballot tables where operationally unavoidable, but these are outside the application-level guarantee and must not be exposed through application interfaces as ballot metadata.

## Result visibility

Before the poll closes:

- individual anonymous ballots are not serialized;
- ballot choices are not returned to the voter who submitted them;
- ballot choices are not returned to coordinators or administrators;
- calculated results are not returned;
- per-option counts are not returned;
- ballots do not appear in topics, timelines, searches, notifications, live updates, exports, or chatbot payloads; and
- no application endpoint may reveal ballot submission order.

The voter may be told only that their vote was recorded.

After the poll closes:

- result calculations may consume detached anonymous ballots;
- authorized users may receive results under ordinary poll access rules;
- individual ballots may be returned only if the product policy chooses to expose them;
- exposed ballots use their UUID primary keys directly; and
- no field-level anonymization should be necessary because the stored ballot contains no identifying metadata.

Publishing individual ballots can permit inference from distinctive voting patterns. Aggregate-only publication offers a stronger privacy property. The product policy must explicitly select which form is presented and exported.

## Participation verification

Participation verification operates only on `AnonymousPollVoter` records. It may establish who was eligible, who invited them, whether they were a group member when invited, and whether they submitted a ballot.

It must never expose or internally derive which ballot belongs to a participant.

Authorization for participation verification must be defined independently from authorization to view poll results. Poll access or result access alone must not imply access to the named electorate ledger.

The UI must describe participation verification as named participation metadata, not ballot identity.

## Automatic reminders

A reminder to vote is sent for anonymous polls whose voting period is at least 24 hours.

The reminder system must:

- use unused `AnonymousPollVoter` records to select recipients;
- run from the existing hourly closing-reminder check;
- send once when the poll enters its final 24 hours;
- calculate eligibility from the current closing time, so deadline changes need no queued-job state;
- skip closed polls and polls whose entire voting period is less than 24 hours;
- avoid exposing the recipient list to participants;
- avoid creating voter-status-derived announcement audiences; and
- avoid carrying ballot data in reminder processing or notifications.

## Submission acknowledgement

After a successful submission, the API and UI tell the voter only that their vote was recorded.

The acknowledgement must not contain:

- ballot choices;
- the ballot UUID;
- a token, hash, or commitment later shown with the ballot;
- a precise submission time; or
- any value that can link the recipient to an exposed ballot.

Suggested wording:

> Your vote was recorded

Submission must not send an email or create a notification or event. The named participation ledger is the only application record of whether an eligible voter submitted.

## Related application systems

### Events and timelines

Submitting an anonymous ballot must not create an event with the ballot as its eventable object. No event actor, event ID, sequence position, child count, or timestamp should need to be hidden because no ballot event exists.

Poll-level events such as opening, closing, and outcome publication may continue normally.

### Notifications, chatbots, and live updates

Submitting an anonymous ballot must not publish shared notifications, chatbot messages, or live updates. A private acknowledgement to the submitting client may state only that submission succeeded.

Closing a poll may publish a poll-level result update after results are available.

### Threads and comments

Anonymous ballots are not thread items and cannot be comment parents. General discussion on the poll topic remains independent from ballot submission.

### Reasons, mentions, and translations

The ballot submission API must reject reason, attachment, mention, and translation parameters rather than persist and suppress them.

### Reactions, bookmarks, and tasks

Anonymous ballots must not implement the reactable, bookmarkable, or task-record interfaces. Requests attempting to use a ballot in these systems must fail authorization or type validation.

### Search

Anonymous ballots must not create search documents. Result summaries and poll outcomes may be indexed after closing under their ordinary rules, but individual ballots must not be indexed.

### Versions and audit history

Anonymous ballots are immutable and must not use PaperTrail or another per-record version system. Participation-state auditing must not record ballot IDs or choices.

## Exports and backups

Application exports must treat the named electorate ledger and detached ballots as separate security domains.

Before closing, application exports must not contain ballots, ballot choices, or calculated results.

After closing, an authorized ballot export may contain only fields that are already safe for application disclosure, including ballot UUIDs and choices if individual-ballot export is part of the selected product policy.

A named participation export may contain authorized `AnonymousPollVoter` fields but must not contain ballot identifiers or choices.

The electorate and ballots should not be placed in the same user-facing export unless there is a documented operational requirement and a security review confirms that the files contain no joinable metadata. The JSON group portability archive is such an operational exception: it includes closed-poll ballots and the participant ledger as separate record sets so a group can be restored, but contains no ballot timestamps or shared vote-to-voter identifier. Ballot identifiers are replaced with export-local UUIDs on every export and replaced again on import.

Raw database backups and operator exports are outside the application-level guarantee. Documentation must not claim that detached storage prevents an infrastructure operator from using transaction-level or backup-level correlation.

## Migration of legacy stance votes

Legacy anonymous polls must be migrated from stance-based votes to detached anonymous ballots. After migration, `Stance` is used only for identified voting and contains no anonymous-voting behavior.

### Migration preconditions

The migration applies only to polls where `anonymous` is true and `voting_system` is `stance`.

Before migrating a poll:

- the poll must be closed;
- no participant may be able to submit, update, revoke, or replace a stance;
- every stance `participant_id` and associated stance-event `user_id` must be null;
- the existing poll totals, option scores, none-of-the-above count, STV input, current-vote count, and non-empty-reason count must be recorded for verification; and
- a database backup must exist because removing identity links and obsolete rich-content records is irreversible.

Active or scheduled legacy anonymous polls must be allowed to close before migration. The migration must not silently close them or remove their electorate while voting is open.

### Vote conversion

Each current submitted vote, represented by a `latest`, non-revoked stance with `cast_at`, becomes one `AnonymousBallot`.

The migration copies:

- `poll_id`;
- `none_of_the_above`; and
- each current stance choice and score.

It does not copy:

- the stance ID;
- participant, inviter, revoker, or redactor IDs;
- tokens;
- creation, update, submission, revocation, or redaction times; or
- sequence or ordering metadata.

Undecided, revoked, and superseded stances do not become ballots. A redacted stance that is still a current submitted vote does become a ballot so its choices continue contributing to the result, but its redacted reason is not restored. The poll's `voting_system` changes to `anonymous_ballot` only after every current vote has been converted and its results have been verified.

### Legacy vote reasons

New detached anonymous votes do not support reasons. Historical non-empty reasons are preserved in dedicated `LegacyAnonymousVoteReason` records associated with their migrated ballots.

`LegacyAnonymousVoteReason` contains an `anonymous_ballot_id` foreign key and normalized plain-text body. It has no timestamps or application-visible identifier. A unique constraint permits at most one legacy reason per ballot.

A legacy vote reason:

- contains only normalized plain text;
- may exist only for a migrated legacy poll;
- has no participant, timestamp, public ID, or ordering metadata;
- cannot be created or edited through an application API;
- does not support attachments, rich-text formatting, link previews, mentions, translations, reactions, bookmarks, tasks, version history, search indexing, events, notifications, or replies; and
- is shown only after the poll has closed.

HTML and Markdown reasons are converted directly to readable plain text. Paragraph and line-break boundaries are retained. Lists, emphasis, links, and mentions retain their readable text but lose formatting and interactive behavior. Redacted reasons are not restored.

The poll results page displays migrated reasons in one read-only **Legacy vote reasons** section below the results. A reason may be displayed with the choices from its migrated vote because writing identifying information is a choice made by the voter. The response must still omit ballot UUIDs, database IDs, timestamps, submission ordering, and system-supplied voter metadata.

This exception does not permit reasons on newly submitted detached anonymous votes and does not make individual ballots without legacy reasons application-visible.

### Attachments and related content

Files attached to a migrated legacy reason are moved to the poll before the stance is removed.

The migration must:

- preserve each Active Storage blob and filename;
- attach the file to the poll without recording or implying a vote author;
- handle duplicate filenames deterministically;
- remove the old stance attachment after the poll attachment exists; and
- purge a blob only when no remaining attachment references it.

Attachment references are removed from the plain-text reason. Link previews, translations, reactions, bookmarks, tasks, versions, mention metadata, and stance search documents are not migrated.

Stance timeline events are removed after any child comments have been reparented to the poll's root event. The comments remain ordinary poll discussion, but no event, reply relationship, or timestamp continues to associate them with an individual migrated vote.

### Electorate and participation records

Where complete `StanceReceipt` records exist, they are used to populate `AnonymousPollVoter` without linking an electorate row to a ballot.

The migration may copy:

- `voter_id`;
- `inviter_id`; and
- submitted or not-submitted state from `vote_cast`.

It must not infer historical group-membership state from current membership. If the historical value is unavailable, migrated electorate records must represent it as unknown rather than false.

Some older polls may not have complete receipts. For those polls, the migration preserves the stored electorate and participation counts but does not invent named electorate rows. Named participation verification is unavailable when its source records do not exist.

### Verification and deletion

Each poll is migrated in its own database transaction. Before deleting its stances, the migration must confirm that the detached ballots produce the same:

- submitted-vote count;
- per-option scores and voter counts;
- none-of-the-above count;
- ranked-choice and score results;
- STV input and result; and
- number of preserved non-redacted reasons.

Any mismatch rolls back the entire poll migration.

After successful verification:

- stance choices and stances for the poll are deleted;
- obsolete stance-owned rich-content records are deleted;
- the poll is marked as a migrated legacy anonymous poll;
- the poll remains permanently closed and cannot be reopened; and
- aggregate result caches are rebuilt from detached ballots.

The legacy marker exists only to enforce archival immutability, display the legacy-format notice and reasons section, and distinguish these polls from the stronger guarantee made for native detached anonymous polls.

## User interface requirements

The poll form must explain that new anonymous voting:

- does not attach names to ballots;
- forces results to remain hidden until voting closes;
- does not permit vote reasons;
- permits only one submission;
- does not allow a voter to review or change their vote after submission.

Suggested form copy:

> Anonymous votes are stored separately from voter identities. Results appear after voting closes. Voters cannot add reasons, review their vote after submitting it, or change their vote.

The confirmation step must warn the voter before submission:

> You cannot review or change your vote after submitting it

After submission, the UI must remove the local ballot choices and show a factual acknowledgement:

> Your vote was recorded

User-facing copy must not claim “complete anonymity,” protection from instance operators, or cryptographic secrecy.

Migrated legacy polls display the factual notice “This poll uses the legacy anonymous voting format”. The notice must not claim the stronger guarantee made for native detached anonymous polls.

## Access boundaries to test

Security tests must exercise each boundary independently:

- signed-out and public users;
- ordinary members;
- eligible voters who have not submitted;
- eligible voters who have submitted;
- non-eligible users;
- poll coordinators;
- group and topic administrators;
- instance administrators using application interfaces; and
- application export operators.

Tests must cover public and private groups, direct and group topics, active and closed polls, each supported poll type, quorum behavior, reminders, early closing, scheduled closing, discarded polls, and permission failures.

Tests must check both direct disclosure and composition attacks across:

- poll and ballot APIs;
- participant verification;
- serializers and side-loaded records;
- events and timelines;
- search;
- live updates;
- notifications and mailers;
- chatbots and webhooks;
- CSV, JSON, thread, group, and backup-oriented exports;
- background jobs;
- error reporting and metrics;
- comments, reactions, bookmarks, tasks, and translations; and
- legacy anonymous poll paths.

A regression test must demonstrate that no application-visible value can join an `AnonymousPollVoter` record to an `AnonymousBallot`.

## Implementation sequence

Implementation should proceed in independently reviewable stages:

1. Approve this specification and resolve its open product decisions.
2. Add the voting-system discriminator without changing existing poll behavior.
3. Add `AnonymousPollVoter`, `AnonymousBallot`, and `AnonymousBallotChoice` with database constraints.
4. Add the dedicated submission service and focused concurrency tests.
5. Add result calculation support without exposing ballots before closing.
6. Add automatic reminders and a generic in-app submission acknowledgement.
7. Add the new poll-form and submission UX.
8. Add participant verification for the new electorate ledger.
9. Audit every related data flow and access boundary listed above.
10. Add user-manual documentation and release notes.
11. Enable the new mode for newly created anonymous polls.
12. Audit, migrate, verify, and remove legacy anonymous stances according to the migration section above.

The legacy migration is an explicitly approved irreversible stage. It must run only after the detached system is deployed, each target poll has closed, backups exist, and per-poll verification is available.

The schema migration only adds the marker and reason storage required by the feature. It must not convert, enqueue, or schedule conversion of any legacy poll.

Legacy stance conversion is performed exclusively through a resumable, manually invoked operator task. Audit eligible polls before changing data:

```sh
DRY_RUN=1 bin/rails loomio:migrate_legacy_anonymous_votes
```

`POLL_ID` limits the task to one poll and `LIMIT` limits the number processed. After confirming a current database backup, run the migration with the backup-confirmation variable present:

```sh
ANONYMOUS_VOTE_BACKUP_CONFIRMED=1 bin/rails loomio:migrate_legacy_anonymous_votes
```

The task commits one verified poll at a time. A failure stops the run without changing the failing poll; already verified polls remain migrated and are excluded when the task is resumed.

## Rollout and legacy removal plan

The rollout is divided into two releases. Stance-specific anonymity code must remain available between them so that active and scheduled legacy polls can close normally.

### Release 1: conversion support

Before merging the conversion release:

1. complete the legacy notice and reason-section translations;
2. add an end-to-end test covering the legacy notice and read-only reasons;
3. add a post-migration audit command covering all stance-owned records;
4. run an actual conversion on a disposable copy of representative production data, including reasons, attachments, incomplete receipts, ranked or scored votes, and STV;
5. verify backup restoration and record the recovery procedure;
6. verify that JSON group and direct-topic export/import preserve detached ballots, choices, participant state, and legacy reasons without preserving ballot identifiers; and
7. complete the anonymous-voting security and code review.

Deploy the detached-voting application code and storage schema before converting data. The deployment:

- enables detached storage for newly created anonymous polls;
- retains stance behavior for existing active and scheduled legacy polls;
- adds the migrated-poll marker and legacy-reason storage;
- adds the read-only legacy notice and reason display; and
- does not automatically convert, enqueue, or schedule any legacy poll.

### Manual conversion

After Release 1 is deployed:

1. Inventory legacy anonymous polls by state and data shape:
   - closed and eligible;
   - active or scheduled and ineligible;
   - reasons present;
   - attachments present;
   - complete or incomplete receipts; and
   - poll type, including ranked, scored, and STV polls.
2. Take a current database backup and verify that it can be restored.
3. Capture the existing dangling-reference baseline before changing any poll:
   ```sh
   CAPTURE_DANGLING_BASELINE_PATH=/secure/path/anonymous-vote-reference-baseline.json \
     bin/rails loomio:audit_legacy_anonymous_votes
   ```
4. Run the manual task with `DRY_RUN` and resolve every precondition failure.
5. Convert individual canary polls with `POLL_ID`. The canaries must cover an ordinary vote, reasons, attachments, ranked or scored choices, STV, complete receipts, and incomplete receipts.
6. For each canary, verify:
   - aggregate results and participation counts;
   - the legacy notice and plain-text reasons;
   - poll-level attachments;
   - participation verification;
   - API responses and access failures;
   - CSV, JSON, group, and poll exports;
   - thread and timeline integrity; and
   - absence of vote identifiers, timestamps, ordering, and named metadata.
7. Convert eligible polls in bounded batches with `LIMIT`. Review the task output and run the post-migration audit after every batch:
   ```sh
   DANGLING_BASELINE_PATH=/secure/path/anonymous-vote-reference-baseline.json \
     bin/rails loomio:audit_legacy_anonymous_votes
   ```
8. Stop on any mismatch. Preserve the failing poll unchanged, investigate it, and resume only after the cause is understood.
9. Allow remaining active and scheduled legacy polls to close normally. Repeat the dry run, canary where necessary, batch conversion, and audit until none remain.

The post-migration audit must confirm:

- no migrated poll contains a stance or stance choice;
- detached vote counts, option totals, none-of-the-above totals, calculated results, and STV results remain valid;
- the number of dangling event, notification, comment parent, reaction, bookmark, task, translation, version, search document, attachment, or announcement stance-ID references does not increase from the pre-conversion baseline; each poll transaction separately verifies that none refer to its exact deleted stance IDs;
- every legacy reason response omits vote and reason record IDs, names, timestamps, and ordering metadata; poll-option IDs already present in ordinary poll serialization may be used to identify the displayed choices;
- poll attachments refer to preserved blobs and no referenced blob was purged;
- incomplete receipt sets did not create invented electorate records; and
- no closed anonymous stance-based poll remains eligible for conversion.

### Release 2: remove stance anonymity

Release 2 may begin only when an audit confirms that no anonymous stance-based poll remains in any state, including active, scheduled, closed, discarded, or archived records.

Release 2 must:

1. make the combination `anonymous = true` and `voting_system = stance` invalid at shared model and service boundaries;
2. remove anonymous behavior from `Stance` and `StanceChoice`;
3. remove anonymous-stance conditions from controllers, serializers, timelines, events, search, attachment queries, exports, reports, mailers, chatbots, and thread rendering;
4. remove legacy stance closing, receipt-building, invitation, and result paths;
5. remove tests and interface branches that support active legacy stance polls;
6. retain migrated detached votes, the legacy marker, plain-text legacy reasons, source receipts, poll-level attachments, the legacy-format notice, and archival immutability; and
7. repeat the complete anonymous-voting security review and focused regression suite before deployment.

The migration is complete only after Release 2 is deployed and the final production audit reports no anonymous stance records or stance-owned references.

## Implemented product decisions

1. Native detached results and ordinary user-facing application exports expose aggregates only, not individual ballots or ballot patterns. The closed-poll JSON group portability archive is the documented operational exception required for restoration. Migrated legacy polls may additionally display a plain-text legacy reason with the choices from that reason's historical vote, without exposing a ballot identifier or metadata.
2. Poll coordinators may view named participation status and invitation provenance. Result access alone does not grant this permission.
3. Group polls establish their electorate when the poll is created. Polls restricted to specified voters use an explicitly invited electorate.
4. Coordinators may add specified voters until the first ballot is submitted. The electorate is frozen after that point.
5. `closing_at` may be extended while voting is open. The hourly check uses the current deadline without maintaining queued-job state. A poll receives at most one automatic closing reminder, including after an extension.
6. The automatic reminder is sent when a poll lasting at least 24 hours enters its final 24 hours. Polls lasting less than 24 hours receive no automatic closing reminder.
7. There is no minimum electorate size.
8. Quorum and participation counts are unavailable through the general poll API before closing. Coordinators may verify named participation separately without receiving ballot contents.
9. New anonymous polls use detached ballots. Supported application APIs cannot enable the legacy anonymous format on an identified poll. Closed legacy anonymous polls are migrated to detached ballots with plain-text legacy reasons and no stance-based voting behavior.
10. General poll comments remain available according to the topic's ordinary comment permissions.
