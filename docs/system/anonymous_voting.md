# Anonymous voting

## Status

This document specifies the design and security guarantees for Loomio's anonymous voting system. It is the normative reference for implementation, review, testing, user documentation, and interface copy.

Anonymous polls use detached ballots. Loomio 3.2 migrated closed polls created
under the legacy stance-based system after per-poll verification. Loomio 3.3
requires that conversion to be complete and prevents anonymous stance polls
from being stored. Vote choices and readable reason text remain preserved.

The implementation distinguishes between identified polls, which use `Stance`,
and anonymous polls, which use detached `AnonymousBallot` records. Anonymous
polls converted from the legacy stance-based system may also contain read-only
plain-text historical reasons.

The voting system is immutable after voting opens.

## Purpose

Anonymous voting should be safe primarily because identifying and correlating data is never stored with a ballot, rather than because serializers and controllers repeatedly remove sensitive fields.

After an anonymous ballot has been submitted, its stored representation should be suitable for disclosure after the poll closes without field-by-field anonymization or identifier substitution.

The named electorate record and the ballot must be separate data sets with no stored relationship between them.

## Terminology

### Identified stance

A response to an identified poll. It is represented by `Stance` and may include a participant, reason, revisions, events, reactions, bookmarks, tasks, translations, comments, mentions, and search indexing.

### Legacy anonymous stance

A historical `Stance` belonging to an anonymous poll created under the previous
voting system. Loomio 3.2 converted these records to detached ballots. Loomio
3.3 refuses to migrate while any remain and does not support them at runtime.

### Anonymous poll voter

A named electorate record for a detached anonymous poll. It records eligibility, invitation provenance, group-membership state at invitation, and whether the person submitted a ballot. It contains no ballot identifier or ballot choices.

### Anonymous ballot

A detached response to an anonymous poll. It contains a random UUID, its poll, and its choices or scores. It contains no participant or electorate reference.

## Security guarantee

For a detached anonymous poll, Loomio records whether each eligible person has submitted a vote, but stores the submitted ballot without a user association. Application users, including poll participants, coordinators, group administrators, and instance administrators using the application, cannot link an individual ballot to its voter.

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
- aggregate subtraction when a coordinator or other participants know every ballot except one, including when a voter is added after voting starts;
- inference from a distinctive ballot pattern; or
- information voluntarily shared by voters.

Protecting ballots from operators with infrastructure access requires a separate cryptographic design. That guarantee must not be implied by interface or user-manual copy.

## Data model

### `AnonymousPollVoter`

`AnonymousPollVoter` is the named electorate and participation ledger for a detached anonymous poll.

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

For a detached anonymous poll, shared model and service boundaries must enforce:

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

A detached anonymous poll uses `AnonymousPollVoter` rather than undecided stances to represent eligible voters.

When voting opens, Loomio must:

1. establish the eligible electorate;
2. create or finalize one electorate record for each eligible voter;
3. record invitation provenance and group-membership state where required;
4. make the poll eligible for the hourly automatic-reminder check; and
5. avoid creating named or undecided stance records.

Coordinators may add eligible voters while the poll is open, including after ballots have been submitted. Group members added to an unrestricted group poll also become eligible while it remains open. Existing electorate records cannot be removed, and late additions must not create a ballot-to-voter correlation path.

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

Participation verification is available only for group-owned polls. Poll coordinators may view names, membership duration, and invitation provenance. The API must omit each person's participation status until at least three people have voted, including after a poll closes below the threshold. Only group administrators may view participant email addresses; other coordinators receive no email value, and email domains are not used as a masked substitute. A missing historical inviter is displayed as unknown rather than preventing verification. Adding a specified voter must update the electorate and cached participation counts in the same poll transaction.

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
- the existing poll totals, option scores, none-of-the-above count, STV input, current-vote count, and non-empty-reason count must be recorded for verification.

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
- may exist only for a closed detached anonymous poll;
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

Stance timeline events are removed after any child comments have been moved to the poll's topic and reparented to the poll's root event. The comments remain ordinary poll discussion, but no event, reply relationship, or timestamp continues to associate them with an individual migrated vote.

After removing the stance events, the migration repairs the complete topic event tree. Before committing, it verifies that every topic event has sequence and position metadata, every parent belongs to the same topic, every child has the expected depth and position-key ancestry, and every cached child count matches the events that remain. A failed repair rolls back the entire poll migration.

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
- the repaired topic event tree passes its parent, depth, position, sequence, and child-count invariants;
- the poll remains permanently closed and cannot be reopened; and
- aggregate result caches are rebuilt from detached ballots.

## User interface requirements

The poll form must explain that anonymous voting:

- does not attach names to ballots;
- forces results to remain hidden until voting closes;
- does not permit vote reasons;
- permits only one submission;
- does not allow a voter to review or change their vote after submission.

Suggested form copy:

> Anonymous votes are stored separately from voter identities. Results only appear after voting closes, and voters cannot add reasons, review their vote after submitting it, or change it.

The confirmation step must warn the voter before submission:

> You cannot review or change your vote after submitting it

After submission, the UI must remove the local ballot choices and show a factual acknowledgement:

> Your vote was recorded

User-facing copy must not claim “complete anonymity,” protection from instance operators, or cryptographic secrecy.

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

## Legacy transition

The transition was divided across two releases so active and scheduled legacy
polls could finish normally.

Loomio 3.2 retained stance-based anonymous voting only for existing
legacy polls. It cleans invalid legacy stances sequentially, then schedules one
delayed, low-priority conversion job per topic. Each job converts the closed
legacy polls in its topic; open and scheduled polls are skipped. Closing a
legacy poll enqueues its topic for conversion. Only one conversion job per topic
may run at a time.

Each poll conversion is transactional and verifies its results, event tree, and
deleted references before committing. Repeated jobs are harmless because a
converted poll is no longer eligible.

Loomio 3.3 refuses to migrate while any anonymous stance-based
poll remains, including active, scheduled, closed, discarded, or archived
records. Once none remain, it prevents the legacy combination at the database
and model boundaries and removes stance-specific anonymous behavior
from application code. Detached ballots, legacy reasons, source receipts, and
poll-level attachments remain available.

Exact upgrade instructions belong in the release notes and
`deploy/UPGRADING.md`.

## Product decisions

1. Native detached results and ordinary user-facing application exports expose aggregates only, not individual ballots or ballot patterns. The closed-poll JSON group portability archive is the documented operational exception required for restoration. Migrated legacy polls may additionally display a plain-text legacy reason with the choices from that reason's historical vote, without exposing a ballot identifier or metadata.
2. Poll coordinators may view invitation provenance. They may view named participation status only once at least three people have voted. Result access alone does not grant this permission.
3. Group polls establish their initial electorate when the poll is created. Polls restricted to specified voters use an explicitly invited electorate.
4. Coordinators may add specified voters while voting is open, including after ballots have been submitted. New group members become eligible in unrestricted group polls while voting remains open. Existing electorate records cannot be removed.
5. `closing_at` may be extended while voting is open. The hourly check uses the current deadline without maintaining queued-job state. A poll receives at most one automatic closing reminder, including after an extension.
6. The automatic reminder is sent when a poll lasting at least 24 hours enters its final 24 hours. Polls lasting less than 24 hours receive no automatic closing reminder.
7. There is no minimum electorate size.
8. Quorum and participation counts are unavailable through the general poll API before closing. Coordinators may verify named participation separately after at least three people have voted, without receiving ballot contents. Status remains hidden if a poll closes below the threshold.
9. New anonymous polls use detached ballots. Supported application APIs cannot enable the legacy anonymous format on an identified poll. Closed legacy anonymous polls are migrated to detached ballots with plain-text legacy reasons and no stance-based voting behavior.
10. General poll comments remain available according to the topic's ordinary comment permissions.
