# STV Elections

**Single Transferable Vote (STV)** is a proportional representation voting method for electing multiple winners from a field of candidates. It ensures that elected candidates proportionally represent the diversity of views among voters.

STV is widely used by organizations like DSA, YDSA, cooperatives, unions, and local governments (Scotland, Ireland, Australia) to run fair multi-winner elections.

## When to use STV

Use an STV Election when you need to:

- Elect a **committee, board, or slate of delegates** from a pool of nominees
- Ensure **proportional representation** — minority factions can win seats proportional to their support
- Run elections where voters rank candidates by preference

STV is **not** the same as Loomio's "Ranked Choice" poll, which is a simpler score-based ranking for choosing a single best option. STV handles multi-winner elections with vote transfers and elimination rounds.

## Creating an STV Election

1. Start a new poll and select **STV Election** as the poll type
2. Add candidates as poll options
3. Configure the STV settings:

### Number of seats

How many winners should be elected. Must be less than the number of candidates.

### Counting method

| Method | Description |
|--------|-------------|
| **Scottish STV** (recommended) | The Weighted Inclusive Gregory Method (WIGM) used in Scottish local elections since 2007. Well-defined, straightforward rules. Best for most organizations. |
| **Meek STV** | A more mathematically precise iterative method. When a candidate is eliminated, votes are recounted as if that candidate was never in the race. Required by YDSA for officer and delegate elections. |

### Quota type

The quota is the number of votes a candidate needs to win a seat.

| Quota | Formula | When to use |
|-------|---------|-------------|
| **Droop** (recommended) | floor(votes / (seats + 1)) + 1 | Standard for most STV elections. Guarantees a majority coalition wins a majority of seats. Used by Ireland, Australia, Scotland. |
| **Hare** | votes / seats | Higher threshold, more proportional for smaller factions. Preferred by DSA chapters to protect minority representation. |

**Example:** With 100 voters and 4 seats, the Droop quota is 21 and the Hare quota is 25.

## How voting works

Voters drag and drop candidates to rank them in order of preference:

- **Rank 1** = most preferred candidate
- **Rank 2** = second choice
- Continue ranking as many candidates as desired

Voters are not required to rank every candidate. Unranked candidates will not receive any of that voter's support.

## How the count works

1. A **quota** is calculated (minimum votes needed to win a seat)
2. **First preferences** are counted for each candidate
3. If a candidate meets the quota, they are **elected**:
   - Their surplus votes (above the quota) are **transferred** to voters' next preferences at a fractional value
4. If no candidate meets the quota, the candidate with the **fewest votes is eliminated**:
   - Their votes transfer to voters' next preferences at full value
5. This process repeats until all seats are filled

### Exhausted ballots

If a voter has ranked no remaining candidates, their ballot is "exhausted" and that vote is lost. This is why ranking more candidates is generally better.

## Understanding results

After the poll closes, results are displayed in several sections:

### Method and quota

At the top, you'll see the counting method (Scottish STV or Meek STV) and quota type (Droop or Hare) along with the quota — the number of votes a candidate needed to win a seat.

### Elected candidates

A summary table of the winners with five columns:

| Column | Meaning |
|--------|---------|
| **Candidate** | The name of the elected candidate |
| **Round elected** | Which counting round they reached the quota and won a seat. Round 1 means they won on first preferences alone; higher rounds mean they needed transferred votes from eliminated or surplus candidates. |
| **First preferences** | How many voters ranked this candidate as their first choice. This shows a candidate's direct support before any vote transfers. |
| **Final tally** | The candidate's vote tally at the moment they were elected (crossed the quota). Due to vote transfers, this is often higher than their first preferences. |
| **Surplus** | How much the candidate's final tally exceeded the quota (final tally minus quota). A larger surplus means stronger support beyond what was needed to win. In Scottish STV, this surplus is redistributed to voters' next preferences. |

### Tied candidates

If the count results in a tie — where eliminating any of the remaining candidates would change the outcome — those candidates are shown in a separate table rather than arbitrarily choosing a winner.

### Round-by-round details

An expandable section showing the full counting process. Each row is a candidate and each column is a counting round, showing vote tallies at each stage:

- **Green highlight** = elected in this round (reached the quota)
- **Red/strikethrough** = eliminated in this round (had the fewest votes)
- **Orange highlight** = tied in this round
- **Faded** = already elected or eliminated in a prior round

## Common configurations

| Organization type | Recommended setup |
|-------------------|-------------------|
| Most organizations | Scottish STV + Droop quota |
| DSA chapters | Scottish STV + Hare quota |
| YDSA elections | Meek STV + Hare quota |
| Government-style | Scottish STV + Droop quota |
