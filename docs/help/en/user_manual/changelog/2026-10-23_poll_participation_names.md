# Clearer voting participation labels

People who have not cast a vote now appear as **Not voted** in poll results. Reminder and announcement audiences use **People who haven't voted**. This describes participation without suggesting whether someone has made up their mind. Voting and access rules stay the same.

For API integrations, poll participation fields now use the following names:

| Previous field | New field |
| --- | --- |
| `decided_voters_count` | `votes_cast_count` |
| `undecided_voters_count` | `votes_uncast_count` |
| `voters_count` | `voters_eligible_count` |
| `cast_stances_pct` | `participation_pct` |
| `stance_counts` | `option_score_totals` |
| `quorum_count` | `quorum_threshold` |
| `quorum_votes_required` | `quorum_gap` |

The audience identifiers `decided_voters` and `undecided_voters` become `voters_cast` and `voters_uncast`. The closing reminder setting also uses `voters_uncast`. Integrations using these fields or identifiers need to adopt the new names. Existing group exports and template files can still be imported.
