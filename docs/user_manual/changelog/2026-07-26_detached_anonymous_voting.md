# Detached anonymous voting

New anonymous polls store the named electorate separately from submitted votes. Submitted votes do not contain a participant, invitation details, a submission time, a written reason, or an identifier shared with the electorate record.

Results stay hidden until voting closes and are then shown as aggregates. Individual voting patterns are not included in application exports. Voters can submit once and cannot review, change, or withdraw their vote after submission. After submission, Loomio shows an acknowledgement without displaying their choices.

Poll coordinators can view the named participation ledger, including who was eligible and whether each person submitted a vote. Other poll participants cannot view this ledger. For explicitly invited electorates, coordinators can add voters until the first vote is submitted.

For anonymous polls lasting at least 24 hours, Loomio automatically reminds eligible people who have not voted during the final 24 hours. Polls lasting less than 24 hours do not send an automatic closing reminder.

This provides application-level separation between names and submitted votes. It does not protect against operators with access to the database, backups, server logs, process memory, or network traffic.

Existing anonymous polls keep the previous stance-based format and behavior. Their votes, reasons, events, comments, reactions, tasks, translations, versions, and exports are not changed or migrated.
