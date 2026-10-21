# Ruby mutation-test audit

This audit strengthens Loomio regressions and reviews overlapping tests against the behavior they protect. Production application, schema and policy code were held fixed while the tests were changed. A shared mutation kill is not a reason to remove distinct access, privacy, storage or workflow checks.

## Evidence and limits

The broad audit covers a fixed application snapshot based on `587929b463`, with the final test changes in `61d2bac474`. Its full Rails suite passed 3,310 tests and 33,339 assertions with zero failures or errors and two existing skips. The exact source/test manifest and local log references are recorded in [validation](mutation_audit_validation.json).

The plan is a reusable queue definition; its pending defaults are not the live audit status. Read the measurement and review ledgers together. Every inventory context is reviewed either against a complete matrix, a structural contract, or a documented environment/runtime limit. “Reviewed” does not mean every mutation was caught or every possible behavior was tested. The [review ledger](mutation_audit_reviews.json) retains survivors, uncovered paths and the reason each test set remains necessary. The [runtime ledger](mutation_audit_runtime_limits.json) retains incomplete attempts without promoting their partial failures to complete evidence.

Existing group/direct fixture roles and the former-member guest case are retained. That guest fixture represents access granted after group membership was revoked. Permission checks for adding guests target the topic. The [direct security review](mutation_audit_security_review.md) distinguishes ordinary members, topic guests, revoked/inactive users, coordinators and instance operators, and preserves session, anonymous-poll and disclosure boundaries separately.

The original 281-context snapshot has the following final dispositions, with no unreviewed contexts:

| Disposition | Contexts |
| --- | ---: |
| Complete mutation matrix and behavioral review | 255 |
| Runtime-limited matrix, reviewed with limits | 12 |
| Structural contract review | 8 |
| Optional-engine limit, reviewed without claiming execution | 4 |
| Aggregate review of existing source profiles | 2 |

The [completion ledger](mutation_audit_completion.json) freezes those signatures, review hashes and raw-report hashes. Exact-ID preservation found no lost detections across 149 comparable contexts and 218 historical complete reports; incomplete matrices are excluded from deletion evidence.

## Application follow-ups

Four application issues were confirmed while production code stayed fixed; they are described in [the findings ledger](mutation_audit_findings.json):

- Viewing a discussion does not redeem the intended pending membership.
- Queued JSON/CSV group exports can outlive an ordinary coordinator's access; the separate trusted-operator export workflow must remain available.
- Bootstrap response normalization loses the intended no-store cache directive.
- Customizing a built-in poll template does not persist its hidden-template entry.

These are follow-up fixes, not behavior changes in this test PR. Other surviving mutations are recorded coverage gaps or scoped observations, not automatically application bugs.

## Integration with current master

Current master changes the shared B2 JSON parameter boundary, moves the help-site schema and updates Ruby dependencies. The old mutation signatures remain historical evidence and must not be relabeled as current. Integration validation on `c52d07f680` plus these test changes passed 3,323 tests and 33,468 assertions with zero failures or errors and two existing skips (405.92 seconds reported by Rails). All 2,279 source/test files matched the frozen manifest after the run. The separate database, updated schema mapping and targeted B2 payload profile keep this evidence distinct from the original matrices. Its complete method matrix catches 22 of 29 candidates, with six survivors and one uncovered wrapper retained after review; 49 selected regressions passed 247 assertions.

The original AGENTS.md workflow link moves into `docs/agents/testing.md`, preserving current master's instruction structure. Raw mutation artifacts remain in ignored temporary directories; another checkout must import or regenerate them before reusing a matrix.

## Ongoing use

Follow [the mutation-testing workflow](mutation_testing.md) for a bounded component or cleanup batch. Establish a green valid control, inspect the remaining mutants, preserve distinct behavior and compare exact IDs before and after each consolidation. The proposed weekly batches and quarterly inventory review are guidance; this PR installs no CI gate, scheduler or recurring automation.
