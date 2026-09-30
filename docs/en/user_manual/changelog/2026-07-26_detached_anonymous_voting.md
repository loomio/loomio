# Detached anonymous voting

New anonymous polls store the named electorate separately from submitted votes. Submitted votes do not contain a participant, invitation details, a submission time, a written reason, or an identifier shared with the electorate record.

Results stay hidden until voting closes and are then shown as aggregates. Individual voting patterns are not included in application exports. Voters can submit once and cannot review, change, or withdraw their vote after submission. After submission, Loomio shows an acknowledgement without displaying their choices.

Poll coordinators can view the named participation ledger, including who was eligible. The ledger shows whether each person submitted a vote only after at least three people have voted; if a poll closes below that threshold, participation status remains hidden. Other poll participants cannot view this ledger. For explicitly invited electorates, coordinators can add voters until the first vote is submitted.

For anonymous polls lasting at least 24 hours, Loomio automatically reminds eligible people who have not voted during the final 24 hours. Polls lasting less than 24 hours do not send an automatic closing reminder.

This provides application-level separation between names and submitted votes. It does not protect against operators with access to the database, backups, server logs, process memory, or network traffic.

Closed polls created with the previous anonymous voting format can be migrated to detached votes. Vote choices and aggregate results are preserved. Historical reasons are converted to plain text and, when present, shown in a read-only legacy reasons section. Files from those reasons are moved to the poll.
