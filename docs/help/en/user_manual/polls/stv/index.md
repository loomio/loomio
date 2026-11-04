<!-- translation-section: introduction -->

# STV Elections

**Single Transferable Vote (STV)** is a proportional representation voting method for electing multiple winners from a field of candidates. It ensures that elected candidates proportionally represent the diversity of views among voters.

<!-- translation-section: when-to-use-stv -->

## When to use STV

Use an STV Election when you need to:

- Elect a **committee, board, or slate of delegates** from a pool of nominees
- Ensure **proportional representation**, where minority factions can win seats proportional to their support
- Run elections where voters rank candidates by preference

>[!NOTE]
>STV is **not** the same as Loomio's [Rank poll](/en/user_manual/polls/rank/), which is a simpler score-based ranking for choosing a single best option. STV handles multi-winner elections with vote transfers and elimination rounds.

<!-- translation-section: creating-an-stv-election -->

## Creating an STV Election

When starting a poll, select **STV Election** as the poll type, then add the candidates as the poll options. You can customize the poll by setting the **number of seats**, the **counting method**, and the **quota type**.

In this example, Oatmilk Cooperative is electing three people to oversee its returnable packaging trial. The form explains the role, lists five candidates, and uses Scottish STV with the Droop quota.

![](form.png)

<!-- translation-section: number-of-seats -->

### Number of seats

How many winners should be elected. Must be less than the number of candidates.

<!-- translation-section: counting-method -->

### Counting method

There are two available methods for counting the votes:

Scottish STV
  : Recommended. The Weighted Inclusive Gregory Method (WIGM) used in Scottish local elections since 2007. Well-defined, straightforward rules. Best for most organizations.
  
Meek STV
  : A more precise method that only a computer can count. When a candidate is elected, Meek keeps passing the part of each vote they do not need on to the voter's later preferences, including votes that reach them later in the count. When a candidate is eliminated, the votes are recounted as if that candidate had never stood. Fewer votes are wasted than in Scottish STV, but the count cannot be checked by hand.

<!-- translation-section: quota-type -->

### Quota type

The quota is the minimum number of votes a candidate needs to win a seat. It can be either:

Droop
  : Recommended. The standard quota for STV elections, used in Ireland, Australia, and Scotland. It is the smallest quota that no more candidates than there are seats can reach. A group of voters who rank their own candidates first wins at least as many seats as the number of quotas they hold. It is calculated as:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : A larger quota. Groups with many votes use more of them on each seat they win, so smaller groups are more likely to win the last seats. It is calculated as:
    \\[ \frac{votes}{seats}\\]

In both formulas, *votes* is the number of ballots that rank at least one candidate.

Meek STV calculates the quota without rounding, as votes ÷ (seats + 1) for Droop. It recalculates the quota each round from the votes still held by candidates, and a candidate must exceed it to be elected.
  
  >[!TIP]
  > Droop will always compute to a smaller number of votes than Hare. For example, in an election with 100 votes and four seats, the Droop quota would be 21 and the Hare quota 25.

<!-- translation-section: how-voting-works -->

## How voting works

In this example, Oatmilk Cooperative is electing three people to oversee the reusable packaging trial. Voters drag candidates above the line and rank them in order of preference:

![](stv-vote-in-progress.png)

- **Rank 1** = most preferred candidate
- **Rank 2** = second choice
- Continue ranking as many candidates as desired

Voters must rank at least one candidate, but do not need to rank every candidate. Unranked candidates will not receive any of that voter's support.

<!-- translation-section: how-counting-works -->

## How counting works
The count is performed as follows:

1. A **quota** is calculated (minimum votes needed to win a seat).
2. **First preferences** are counted for each candidate.
3. Every candidate who meets the quota is **elected**. Their surplus votes (above the quota) are **transferred** to voters' next preferences at a fractional value, largest surplus first. Votes only transfer to candidates who are still in the count.
4. If no surplus is left to transfer, the candidate with the **fewest votes is eliminated**. Their votes transfer to voters' next preferences at full value.
5. When the number of candidates left equals the number of seats left, they are all elected, even if they have not reached the quota.
6. Otherwise the count repeats from step 3 until all seats are filled.

The fractional value shares out only the votes a winner does not need. For example, if the quota is 26 and a candidate has 40 votes, their surplus is 14. Each of their 40 ballots moves to its next preference worth 14 ÷ 40 = 0.35 of a vote.

In Scottish STV, each transferred vote's value is rounded down to five decimal places, as in Scottish council elections.

If two or more candidates have the fewest votes, the one with fewer votes at the most recent earlier round is eliminated.

>[!TIP]
>A ballot counts only while it ranks a candidate who is still in the count. When none are left, the ballot is "exhausted" and no longer counts.

<!-- translation-section: understanding-results -->

## Understanding results

After the poll closes, results are displayed in several sections. In this election, Samira Patel, Alex Morgan, and Morgan Price fill the three committee seats:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Method and quota

At the top, you'll see the counting method (Scottish STV or Meek STV) and quota type (Droop or Hare) along with the quota — the number of votes a candidate needed to win a seat.

<!-- translation-section: elected-candidates -->

### Elected candidates

A summary table of the winners with five columns:

| Column | Meaning |
|--------|---------|
| **Candidate** | The name of the elected candidate |
| **Round elected** | Which counting round they reached the quota and won a seat. Round 1 means they won on first preferences alone; higher rounds mean they needed transferred votes from eliminated or surplus candidates. |
| **First preferences** | How many voters ranked this candidate as their first choice. This shows a candidate's direct support before any vote transfers. |
| **Final tally** | The candidate's vote tally at the moment they were elected. Due to vote transfers, this is often higher than their first preferences. |
| **Surplus** | How much the candidate's final tally exceeded the quota (final tally minus quota). A larger surplus means stronger support beyond what was needed to win. In Scottish STV, this surplus is redistributed to voters' next preferences. |

Sometimes earlier rounds cannot break a tie. If the tie does not change who is elected, the count continues. If it does, the count stops at that round. Candidates who win however the tie is broken are shown as elected. Candidates who could win or lose depending on the tie are shown in a separate table. Loomio shows them as tied instead of choosing one at random.

<!-- translation-section: round-by-round-details -->

### Round-by-round details

Expand **Round-by-round details** to see vote transfers and eliminations. Each row is a candidate and each column is a counting round. Each number is the votes the candidate held at the start of that round:

![](stv-results.png)

The green highlight shows when a candidate was elected, red shows when they were eliminated, and orange shows when they tied.

<!-- translation-section: share-an-outcome -->

## Share an outcome

When the election closes, share an outcome. Name the people elected and say when their role starts. See [Share an outcome](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) for how outcomes work.

![An outcome naming the elected committee members](outcome.png)

<!-- translation-section: exporting-ballots -->

## Exporting ballots

After the election closes, people who can view the results can export the ballots in BLT format for an independent recount or audit. The export contains candidate rankings and combines identical rankings into a single row with a ballot count. For anonymous elections it does not contain voter identities, ballot identifiers, submission times, or submission order.
