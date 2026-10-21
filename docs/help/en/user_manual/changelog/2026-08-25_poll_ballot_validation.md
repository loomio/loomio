# Poll ballot validation

Loomio now applies each poll type's score, choice-count, dot-vote, and ranking rules before storing a vote. Crafted ballots with negative or excessive scores, contradictory choices, duplicate options, or invalid rankings are rejected without changing the poll result.

Negative score scales are no longer supported. Use a nonnegative scale such as `0..10`, with 5 as the neutral value, when a poll needs values on both sides of a midpoint.
