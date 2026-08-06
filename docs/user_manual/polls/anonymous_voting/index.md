# Anonymous voting

Anonymous voting separates the record of who has voted from the votes themselves. Poll coordinators can see who was eligible and, once at least three people have voted, verify participation. Application users cannot connect a submitted vote with the person who submitted it.

This page explains the protections provided by anonymous voting, the information that is retained, and the limits of the guarantee.

## How anonymous voting protects voters

An anonymous poll keeps two separate sets of records:

| Participation records | Submitted votes |
| --- | --- |
| Who is eligible to vote | The selected options or scores |
| Who was invited, and by whom | The poll the vote belongs to |
| Whether each eligible person has voted | No name or user account |
| No selected options or scores | No link to a participation record |

There is no shared identifier that connects these records. Submitted votes also omit the actual submission time, invitation information, written reasons, attachments, and other metadata that could help identify a voter.

This separation is enforced when the vote is stored. It does not depend only on hiding names in the interface.

## While voting is open

Results remain hidden from everyone until the poll closes. This includes poll coordinators, group administrators, and instance administrators using the application.

When someone votes:

- their submitted vote is stored without their name or participation record;
- their participation record is marked to show that they have voted;
- no vote event, notification, email, comment, or activity entry is created;
- no copy of their selections is returned after submission; and
- the interface confirms only that their vote was recorded.

The participation record does not store a precise time for when the person voted. Submitted votes are not ordered by submission time.

## Votes cannot be changed

Each eligible person can vote once. A submitted anonymous vote cannot be reviewed, changed, withdrawn, or replaced, including by a coordinator or administrator.

Allowing a person to retrieve or replace their vote would require a persistent link between that person and the vote. Anonymous voting deliberately does not create that link.

Review your selections carefully before submitting.

## Why anonymous votes do not have reasons

New anonymous votes cannot include a written reason or an attachment. Reasons can contain names, personal details, writing patterns, mentions, or other information that identifies the voter. They would also make individual votes easier to distinguish from the aggregate result.

Participants can still discuss the poll in its thread where discussion is available. Those comments are ordinary named discussion contributions and are not attached to an anonymous vote.

## Results and exports

After the poll closes, the results are calculated from the detached votes and displayed as totals and other aggregate results supported by the poll type.

The application does not publish individual voting patterns, vote identifiers, submission order, or submission times. Poll exports contain aggregate results rather than a row for each anonymous vote.

An anonymous poll cannot be reopened after it closes.

## Participation verification

Poll coordinators can view the named participation records. These always show who was eligible. Once at least three people have voted, they also show whether each person voted, but never show how anyone voted. If a poll closes with fewer than three votes, the participation status remains hidden.

Other participants cannot view this named participation information. Access to poll results does not grant access to the participation records.

For a poll limited to explicitly invited people, coordinators can add voters until the first vote is submitted. Restricting electorate changes after voting begins reduces the information that could be used to infer how someone voted.

## Reminders

For an anonymous poll lasting at least 24 hours, eligible people who have not voted receive one automatic reminder during the final 24 hours.

The reminder is selected from participation records only. It does not inspect submitted votes or create a connection to them. If the deadline changes, the hourly reminder check uses the current deadline without maintaining a separate scheduled reminder for the poll.

Polls with a total voting period of less than 24 hours do not send this automatic reminder.

## What coordinators and administrators can see

Through the application, a poll coordinator, group administrator, or instance administrator may be able to see:

- the poll and its eligible voters;
- whether each eligible person has voted, where their role permits access and at least three people have voted; and
- aggregate results after the poll closes.

They cannot use application features to see:

- which selections belong to a person;
- individual votes or voting patterns;
- when a particular vote was submitted; or
- a reason, attachment, event, or notification associated with a submitted vote.

## Limits of anonymous voting

These protections prevent application users from linking a submitted vote to its voter. They are not a cryptographic protection against an operator who can inspect the database, backups, server logs, process memory, network traffic, or a modified version of the application.

The result itself may also reveal information. A small electorate, a unanimous result, a distinctive combination of selections, or information shared outside the poll can make a person's choices easier to infer. Voters may also choose to identify themselves in discussion outside their submitted vote.

Consider the size of the electorate and the sensitivity of the decision when deciding whether application-level anonymous voting is suitable.

## Older anonymous polls

Older anonymous polls used a legacy format in which votes were stored using the same records as identified votes. These polls display:

> This poll uses the legacy anonymous voting format

The stronger protections described above apply to anonymous polls created with the detached voting format, not to activity that occurred under the legacy format.

When an older closed poll is migrated:

- its choices are preserved and used to calculate the same aggregate results;
- historical reasons are converted from formatted content to plain text;
- those reasons appear together in a read-only **Legacy vote reasons** section below the results;
- attachments from historical reasons are moved to the poll;
- reactions, replies, revisions, translations, mentions, and other rich interactions attached to historical votes are not retained as vote features; and
- names, timestamps, identifiers, and submission order are not displayed with the migrated votes or reasons.

A historical reason may identify its author through what they chose to write. That is information the voter supplied, rather than a system-created link between their name and vote. New anonymous votes do not allow reasons.

## Questions

### Can a coordinator see how I voted?

No. Once at least three people have voted, a coordinator can verify whether you voted but cannot connect you with a submitted vote through the application. Below that threshold, your participation status remains hidden.

### Can I see my vote after submitting it?

No. The application confirms that your vote was recorded, then discards the selections from the voting interface. It cannot retrieve your vote without creating the link that anonymous voting is designed to avoid.

### Can I change or withdraw my vote?

No. There is no link that would let the application identify which submitted vote to change or remove.

### Will I receive an email confirming my vote?

No. Voting creates only the on-screen acknowledgement and updates your participation record. It does not send a confirmation email or create a notification or activity event.

### Does a public poll reveal more information?

Public access may allow people to see the poll and its aggregate results after it closes. It does not expose the named participation records or individual anonymous votes.

### Is anonymous voting suitable for every election?

No. It provides application-level separation between identities and votes. Decisions requiring protection from system operators or independently verifiable cryptographic elections need a system designed for those requirements.
