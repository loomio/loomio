# Anonymous voting

## Status

This document specifies the intended design and security guarantees for Loomio's new anonymous voting system. It is the normative reference for implementation, review, testing, user documentation, and interface copy.

The new system is additive. It does not change or migrate existing anonymous polls. Existing anonymous stances, reasons, thread items, reactions, bookmarks, tasks, translations, events, versions, and exports must remain intact.

The implementation must distinguish between:

- identified polls, which use `Stance`;
- legacy anonymous polls, which continue to use the existing stance-based behavior; and
- new anonymous polls, which use detached `AnonymousBallot` records.

The exact database field used to identify the voting system is an implementation decision, but it must be immutable after voting opens.

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

Existing `StanceReceipt` records must remain available for historical and legacy polls. They must not be destructively migrated or deleted as part of this project.

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
3. lock the voter's `AnonymousPollVoter` record;
4. confirm that voting is open and the electorate record is unused;
5. validate choices against the poll and poll options;
6. create a detached `AnonymousBallot` and its choices without a user association;
7. mark the electorate record as used without storing the ballot UUID;
8. commit the ballot and participation-state change atomically.

The database constraint and row lock must prevent duplicate or concurrent submissions.

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

The electorate and ballots should not be placed in the same user-facing export unless there is a documented operational requirement and a security review confirms that the files contain no joinable metadata.

Raw database backups and operator exports are outside the application-level guarantee. Documentation must not claim that detached storage prevents an infrastructure operator from using transaction-level or backup-level correlation.

## Legacy anonymous polls

Legacy anonymous polls retain their existing stance-based behavior.

This project must not:

- delete or rewrite historical stance reasons;
- delete historical stances or stance choices;
- remove participant links from existing open polls outside their established lifecycle;
- delete thread items, comments, reactions, bookmarks, tasks, translations, events, versions, or search records;
- rewrite historical identifiers or timestamps;
- change historical exports; or
- claim the new guarantee for legacy records.

Legacy polls must remain readable and operational under their current behavior. New poll creation should use the detached anonymous ballot system once it is available.

Any future migration of legacy polls is a separate project requiring explicit product approval, a preservation plan for user content, and a complete security review.

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

Legacy anonymous polls may display the factual notice “This poll uses the legacy anonymous voting format”. The notice must not imply that historical content will be removed or rewritten.

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

No stage may destructively migrate legacy anonymous poll content.

## Implemented product decisions

1. Results and application exports expose aggregates only, not individual detached ballots or ballot patterns.
2. Poll coordinators may view named participation status and invitation provenance. Result access alone does not grant this permission.
3. Group polls establish their electorate when the poll is created. Polls restricted to specified voters use an explicitly invited electorate.
4. Coordinators may add specified voters until the first ballot is submitted. The electorate is frozen after that point.
5. `closing_at` may be extended while voting is open. The hourly check uses the current deadline without maintaining queued-job state. A poll receives at most one automatic closing reminder, including after an extension.
6. The automatic reminder is sent when a poll lasting at least 24 hours enters its final 24 hours. Polls lasting less than 24 hours receive no automatic closing reminder.
7. There is no minimum electorate size.
8. Quorum and participation counts are unavailable through the general poll API before closing. Coordinators may verify named participation separately without receiving ballot contents.
9. New anonymous polls use detached ballots. Supported application APIs cannot enable the legacy anonymous format on an identified poll. Existing legacy anonymous polls remain unchanged.
10. General poll comments remain available according to the topic's ordinary comment permissions.
