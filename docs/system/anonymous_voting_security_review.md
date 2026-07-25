# Anonymous voting security review

## Scope

This review covers the detached anonymous voting implementation described in `anonymous_voting.md`. Legacy anonymous polls remain stance-based and are outside the new anonymity guarantee.

## Storage boundary

- `AnonymousPollVoter` contains the named electorate and a submitted/not-submitted boolean. It has no ballot identifier, choice, score, or timestamp.
- `AnonymousBallot` uses a random UUID primary key and contains only its poll and `none_of_the_above`.
- `AnonymousBallotChoice` has no primary key, timestamp, user reference, or sequence value.
- The electorate and ballot tables share only `poll_id`, which identifies the poll rather than a voter-to-ballot relationship.
- Database constraints prevent duplicate electorate entries and duplicate options within a ballot.
- Ballots, choices, and voting configuration become immutable after submission.

## Submission boundary

- The dedicated service authenticates and authorizes the voter, locks their electorate row, validates choices against the poll, creates the ballot, and marks participation in one transaction.
- A used electorate row cannot submit again. Concurrent requests serialize on the same electorate-row lock.
- The response contains only `recorded: true`.
- Unsupported fields, including reasons and attachments, are rejected. Ballot request parameters are filtered from application logs.
- Submission creates no stance, ballot event, topic item, search document, live update, shared notification, version, reaction, bookmark, task, translation, mention, comment, or chatbot payload.

## Visibility and composition

- Before closing, general poll serialization omits results, option counts, cast/uncast counts, participation percentages, quorum progress, and STV results.
- The current voter receives only their own eligibility and submitted/not-submitted state.
- Named participation verification is coordinator-only and uses only electorate records.
- The ballot API has no show, index, update, destroy, revoke, redact, or replace route.
- After closing, charts and CSV exports use aggregate option totals. BLT ballot-pattern export is denied.
- Ballots are not side-loaded through stance, event, topic, notification, search, thread, group, or chatbot serializers.

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
- Legacy polls continue through existing stance serializers, events, exports, and closing behavior.

## Residual risks

The application-level design does not protect against database, backup, host, process-memory, transaction-log, network-timing, mail-system, or server-log operators. Small electorates and distinctive aggregate patterns can also permit inference. The UI and user documentation must not describe the feature as cryptographically anonymous or protected from infrastructure operators.
