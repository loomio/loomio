<!-- translation-section: introduction -->

# Anonymous voting

Anonymous voting, also known as blind voting, separates the record of who voted from the votes themselves. After the poll closes, anyone who can see the results can see who took part, but no one using Loomio can connect a vote to the person who cast it.

This page explains how anonymous voting works, what information is kept, and the limits of this protection.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## How anonymous voting protects voters

An anonymous poll keeps two separate sets of records:

| Participation records | Submitted votes |
| --- | --- |
| Who is eligible to vote | The selected options or scores |
| Who was invited, and by whom | The poll the vote belongs to |
| Whether each eligible person has voted | No name or user account |
| No selected options or scores | No link to a participation record |

No shared ID connects these records. Submitted votes also omit submission times, invitation details, vote reasons, attachments, and other metadata that could identify a voter.

This separation happens when the vote is saved—it does not rely on merely hiding names in the interface.

<!-- translation-section: while-voting-is-open -->

## While voting is open

Results stay hidden from everyone until the poll closes, including thread admins, group admins, and instance admins.

When someone votes:

- their vote is stored without their name or participation record;
- their participation record is marked as having voted;
- no vote event, notification, email, comment, or activity entry is created;
- no copy of their choices is returned after submission; and
- the screen confirms only that their vote was recorded.

The participation record does not store the exact time a person voted, and submitted votes are not ordered by submission time.

<!-- translation-section: votes-cannot-be-changed -->

## Votes cannot be changed

Each eligible person can vote once. A submitted anonymous vote cannot be reviewed, changed, withdrawn, or replaced—not even by an admin.

Letting someone retrieve or replace their vote would require a link between that person and their vote, which anonymous voting intentionally avoids.

Review your choices carefully before submitting.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Why anonymous votes do not have reasons

Anonymous votes cannot include a vote reason or an attachment. Reasons can contain names, personal details, writing patterns, or mentions that identify the voter, and could make individual votes easier to pick out from the results.

Participants can still discuss the poll in its thread. Those comments are ordinary named contributions and are not linked to an anonymous vote.

<!-- translation-section: results-and-exports -->

## Results and exports

After the poll closes, Loomio calculates the results from the detached votes and displays the totals for that poll type.

Loomio does not publish vote IDs, submission order, or submission times. Poll exports contain only aggregate results rather than a row for each vote. The one exception is a closed STV election, which can be exported in BLT format for recounting. A BLT export lists the candidate rankings (grouped when multiple ballots match) without voter identities or ballot metadata.

An anonymous poll cannot be reopened after it closes.

<!-- translation-section: participation-verification -->

## Who took part

After an anonymous poll closes, anyone who can see its results can see who took part. No one can see this while voting is open.

Select **View votes** to see the list. It always shows who was eligible to vote, and never shows how or when anyone voted. Whether each person voted appears only if enough people took part: at least the poll's quorum (if set), otherwise at least half of eligible voters, and never fewer than three votes.

Group members and the poll's voters also see when each person joined the group and who invited them. Group admins also see email addresses, to tell apart people with the same name.

Because everyone who can see the results can see who voted, a one-sided result can reveal how people voted. For example, if every vote is Agree, everyone who voted agreed.

Admins can add eligible voters while voting is open, even after others have voted. Existing voters cannot be removed from an anonymous poll.

<!-- translation-section: reminders -->

## Reminders

For an anonymous poll lasting at least 24 hours, eligible people who have not voted receive one automatic reminder during the final 24 hours.

Loomio selects recipients from participation records only, without checking submitted votes.

Polls with a voting period shorter than 24 hours do not send this automatic reminder.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## What admins can see

Through the application, a thread admin, group admin, or instance admin may be able to see:

- the poll and its eligible voters;
- whether each eligible person has voted (when their role permits access and enough people have voted); and
- aggregate results after the poll closes.

They cannot use the application to see:

- which choices belong to a person;
- individual votes or voting patterns;
- when a vote was submitted; or
- a vote reason, attachment, event, or notification linked to a vote.

<!-- translation-section: limits-of-anonymous-voting -->

## Limits of anonymous voting

Anonymous voting prevents Loomio users from linking a vote to a voter. It is not cryptographic protection against a server operator who can inspect the database, backups, server logs, process memory, network traffic, or modified code.

The results themselves can also give clues. A small group, a unanimous vote, a unique combination of choices, or comments shared outside the poll can make a person's vote easier to infer.

Consider the size of the group and how sensitive the decision is before relying on application-level anonymous voting.

<!-- translation-section: questions -->

## Questions

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Can anyone see how I voted?

No. No one using Loomio can connect you to your vote. Once enough people have voted, anyone who can see the results can see whether you took part. Before that threshold is reached, even whether you voted stays hidden.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Can I see my vote after submitting it?

No. Loomio confirms that your vote was recorded and clears your selections from the screen. It cannot retrieve your vote without creating the link that anonymous voting avoids.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Can I change or withdraw my vote?

No. Because there is no link between you and your vote, Loomio cannot identify which vote to change or remove.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Will I receive an email confirming my vote?

No. Voting shows only an on-screen confirmation and updates your participation record. It does not send an email or create a notification or activity entry.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Does a public poll reveal more information?

After a public poll closes, anyone can see its results and who took part. They cannot see individual votes or membership and invitation details.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Is anonymous voting suitable for every election?

No. It provides application-level separation between voters and votes. Elections that require protection from server operators or independent cryptographic verification need a system built for those requirements.
