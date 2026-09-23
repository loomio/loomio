# Ballot validation

## Status

This document specifies how Loomio validates poll ballots. It is the normative
reference for poll-type configuration, identified stances, detached anonymous
ballots, and tests that protect result integrity.

Ballot validation is a storage-boundary invariant. Client forms may guide a
participant towards a valid ballot, but the server must reject malformed API
requests without changing the previous ballot, result counters, or events.

## Data paths

Loomio stores ballots through two models:

- identified polls use `Stance` and `StanceChoice`;
- detached anonymous polls use `AnonymousBallot` and
  `AnonymousBallotChoice`.

Both parent models include `ValidatesBallot`. This shared validation boundary
prevents their score and choice-count rules from drifting apart. Choice models
also require scores to be integers and ensure that each option belongs to the
ballot's poll.

`ValidatesBallot` owns shared parent-record integrity: options must be unique,
every option must belong to the ballot's poll, and `none_of_the_above` cannot be
combined with choices. The concern also applies configured score, choice-count,
dot-budget, and ranking rules to the complete ballot. Voting-system eligibility,
stance reasons, and record lifecycle checks remain on their respective models.

An undecided `Stance` is allowed to have no choices. The complete ballot is
validated once `cast_at` is present. An `AnonymousBallot` is always a submitted
ballot and is validated whenever it is saved.

## Configuration

Every entry in `config/poll_types.yml` must declare a `ballot_rule`. There are
no optional `validate_*` switches. Omitting a rule is invalid configuration;
it must never mean that validation is skipped.

Scalar defaults such as `min_score`, `max_score`,
`minimum_stance_choices`, `maximum_stance_choices`, and `dots_per_person`
remain under the poll type's `defaults` section. The validator reads the
effective values from first-class columns on the instantiated poll, falling
back to the poll-type defaults. Legacy values in `custom_fields` are ignored for
all ballot validation properties. The ballot-configuration backfill migration
copies valid legacy integers into empty columns, preserves existing column
values, and leaves the now-ignored JSON unchanged.

The built-in poll templates are constructed by applying the defaults from
`poll_types.yml` and then the overrides from `poll_templates.yml`. A selected
template is copied into a new poll and may be edited before creation. Saved
group templates and existing polls are persisted snapshots; changing a YAML
default does not reliably rewrite them. Validation therefore operates on the
poll rather than trusting the template that created it.

## Ballot rules

| Rule | Poll types | Required invariant |
| --- | --- | --- |
| `bounded` | count, check, proposal, meeting, poll, score | Choice count and every score are within the poll's effective bounds |
| `dot_vote` | dot vote | Bounded choices and scores, with the sum no greater than `dots_per_person` |
| `ranked_points` | rank | Exactly the configured number of choices, with scores forming the unique contiguous sequence `1..N` |
| `ranked_preferences` | STV | Any permitted number of choices, with scores forming the unique contiguous sequence `1..N` |
| `reason_only` | question | No ballot choices |

For Rank, the client sends the first preference with the highest point score,
but the set of valid scores is still `1..N`. For STV, the client sends rank 1
for the first preference. The validator checks the score sequence as a set;
the counting code interprets its direction according to the poll type.

`none_of_the_above` is validated separately. When it is selected, the ballot
must contain no choices and the poll must permit that response.

## Fixed-score ballots

Proposal, count, check, and ordinary fixed-score poll choices have an effective
minimum and maximum score of 1. A selected option must therefore have score 1;
zero is not an alternative representation of a selected option.

Meeting, score, and dot-vote polls may legitimately use zero. No poll type
permits a negative score. A score poll that needs a bipolar scale must translate
it to nonnegative values; for example, `-5..5` becomes `0..10`, with 5 as the
neutral value. The global nonnegative rule is applied before the poll's more
specific effective bounds.

## Ranked ballots

Bounds alone are insufficient for ranked ballots. Values such as `[3, 3, 1]`
or `[1, 2, 9999]` may fall partly within plausible bounds but do not represent
a valid ordering. Rank and STV therefore require unique, contiguous scores.

Rank polls use the configured `minimum_stance_choices` as the exact number of
ranked options. When `require_all_choices` is enabled, the effective minimum is
the number of poll options.

STV permits a participant to rank no candidates or any subset up to the poll's
effective maximum. A non-empty STV ranking must start at 1 and contain no gaps
or duplicate ranks.

## Atomic failure behavior

`StanceService` and `AnonymousBallotService` save ballots and update derived
poll counts inside database transactions. A validation failure must:

- return an unprocessable-entity response through the API;
- leave the participant's previous identified ballot unchanged;
- leave poll-option and poll counters unchanged;
- create no stance event;
- leave an anonymous electorate record unused; and
- store no detached anonymous ballot or choices.

Authorization and ballot integrity are separate boundaries. A participant,
coordinator, group administrator, or instance administrator may have different
permissions to submit or manage a poll, but no role may bypass ballot
validation.

## Result calculations

Poll-option counts and result calculations consume stored scores without
clamping them. Clamping at the result layer would conceal corrupt data and make
the displayed result disagree with the stored ballot. Integrity must be
enforced before storage.

Direct SQL writes and APIs such as `insert_all!` can bypass model validation.
Both choice tables therefore have a database check constraint enforcing
`score >= 0`. Poll-relative bounds, dot budgets, and ranked sequences cannot be
expressed by that row-local constraint and remain shared ballot-level rules.

## Existing nonconforming data

Historical negative-scale polls and ballots remain stored and their closed
results continue to display the original values. The two `score_nonnegative`
database constraints intentionally remain `NOT VALID`: PostgreSQL enforces them
for every new or updated choice without revisiting historical rows.

Historical poll records are not revalidated merely because another attribute
is saved. Score-bound validation runs when a poll is created or its first-class
minimum or maximum score changes. This keeps the new-write rule independent of
legacy records that Loomio has no reason to rewrite.

## Adding or changing a poll type

When adding or changing a poll type:

1. Select an existing `ballot_rule` or extend the validator with a rule that
   describes the complete ballot invariant.
2. Define every applicable scalar default in `poll_types.yml`.
3. Check whether entries in `poll_templates.yml` override those defaults.
4. Test the lowest and highest valid scores and choice counts.
5. Test negative scores, excessive scores, excessive choices, and empty
   ballots.
6. For ranked ballots, test duplicate, discontinuous, and inflated ranks.
7. Run the same relevant cases through identified and detached anonymous
   ballots.
8. Test create and update API paths and confirm that failed updates preserve
   stored ballots and derived results.
9. Keep the configuration-completeness test updated so every poll type has a
   known policy and no `validate_*` switches are reintroduced.
