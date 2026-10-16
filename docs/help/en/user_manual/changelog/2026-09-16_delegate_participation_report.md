## Delegate activity in participation reports

Participation reports now have a **Delegates only** filter in the **Actions per user** table. A person is included when they are currently a delegate in any selected group, and their activity is aggregated across all selected groups. Delegates with no activity in the selected period remain visible, and CSV downloads follow the same filter.

The report also has a **Voting record per user** section showing how many identified ballots were issued to each person, how many they cast or missed, and whether they cast every ballot issued to them. These counts are available for all users and through the report API; anonymous polls are excluded from per-person voting records.

Poll and thread invitee lists now identify delegates with a **Delegate** badge. Integrations can retrieve the same aggregate report through the User API.
