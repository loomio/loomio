# STV Election counting fixes

STV Election counts now follow the Scottish counting rules more closely. Loomio's Scottish STV count now matches the official stage reports of eight Scottish council wards, round by round. Closed elections keep the results they were announced with. STV Elections are no longer marked as beta: the poll form no longer shows a warning about untested counting.

- **Candidates who reach the quota in the same round are elected together.** Their surpluses transfer largest first, and only to candidates still in the count. Previously one winner's surplus could transfer to another winner and be lost, which could elect the wrong candidate.
- **Transfer values are rounded down to five decimal places** in Scottish STV, as the Scottish rules require. Meek STV uses the exact quota, votes ÷ (seats + 1), without rounding.
- **Ties are broken by earlier rounds.** When candidates tie for elimination, the one with fewer votes at the most recent earlier round is eliminated. Previously the tie was broken by the order of the candidates. If earlier rounds cannot break a tie and the tie changes who is elected, the results show the candidates who could win as tied.
- **Voters must rank at least one candidate.** The Submit button is disabled until a candidate is ranked. Blank ballots no longer count towards the quota.
- **Poll settings are checked.** The number of seats must be at least one and less than the number of candidates.
