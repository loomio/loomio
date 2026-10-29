# More precise poll voting times

Proposals and polls now keep the opening and closing times you select, including **23:59** (11:59pm). This fixes a problem where saving a poll rounded its selected time down to the hour.

Scheduled polls now open closer to their selected time, including in time zones with half-hour and quarter-hour offsets. Opening and closing are checked every minute. Voting stops accepting responses at the selected closing time; results and notifications follow as background work completes.
