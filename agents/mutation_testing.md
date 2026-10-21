# Reviewing Ruby tests with mutation testing

Use Mutineer's kill matrix to find missing behavioral checks and review overlapping model, controller, service, and permission tests. The objective is an understandable set of tests that protects Loomio's behavior. A mutation score describes the selected sources, tests, and operators; it does not establish that the application has no bugs or that a test is unnecessary.

Use this workflow for a targeted audit or planned test-suite cleanup. Begin with one component, keep production code fixed while comparing test changes, and record the result before expanding the scope.

## Establish the scope

1. Read the service, its callers, and the tests. List the behaviors the tests protect, including error handling, side effects, boundary values, and historical regressions. Include sibling test files when a service's coverage is split across them.
2. Run the selected tests against the unmodified implementation. Resolve test failures and environment problems before interpreting mutations.
3. Choose a fault model. Start with the default operators, then add operators relevant to the service, such as condition forcing, collection-method changes, and nil returns. Add literal or regex mutations when those rules matter. Record the exact operator list and Mutineer version so before and after runs are comparable.
4. Use the full selected source for test cleanup. `--since` scopes changed source lines; it can omit the behavior that makes an otherwise overlapping test necessary, and a test-only change can leave it with no mutations to run.

For voting, anonymous polls, permissions, authentication, or sessions, follow the security-review requirements in `AGENTS.md` and review the affected boundaries directly. Keep successful and denied paths, the reusable access-control fixture matrix, privacy protections, and session lifecycle regressions. A shared mutation kill does not make different roles, privacy modes, or workflows interchangeable.

## Run a kill matrix

The pilot used Mutineer 1.6.0 with Ruby 4.0.5, Rails 8.1, Minitest 6, and PostgreSQL. Install the tool into the checkout's ignored temporary directory to keep the audit reproducible without changing application dependencies:

```sh
gem install mutineer --version 1.6.0 --install-dir tmp/mutineer/gems --no-document
mkdir -p tmp/mutineer/reports

RAILS_ENV=test bundle exec ruby tmp/mutineer/gems/gems/mutineer-1.6.0/bin/mutineer run \
  app/services/throttle_service.rb \
  --test test/services/throttle_service_test.rb \
  --rails --jobs 1 --timeout 30 --matrix \
  --operators comparison,arithmetic,boolean_connector,boolean_literal,statement_removal,return_nil,condition_negation,condition_true,condition_false,collection_method \
  --cache-dir tmp/mutineer/cache/throttle \
  --format json --output tmp/mutineer/reports/throttle-before.json
```

Repeat `--test` for additional relevant files. Use separate report names for before and after runs and separate cache directories for independent audits. Keep reports in `tmp/`; record the meaningful results and decisions in the change description.

Use the checkout's configured Ruby and test database. Linked worktrees derive their own database name through `TestDatabaseUrl` unless `DATABASE_URL` or `TEST_DATABASE_URL` overrides it. Run tests sharing a database serially and observe the Rails/E2E exclusion in `AGENTS.md`.

On the macOS setup used for the pilot, PostgreSQL connection initialization crashed in a forked child until `PGGSSENCMODE=disable` was prepended to the test command. This setting was needed only for the local audit process. Investigate capture failures before treating any output as evidence about tests.

In this release, `--matrix` uses the in-process backend and cannot be combined with `--daemon`, `--test-command`, or `--fail-fast`. Rails in-process runs are serial. The default operators alone produced only seven throttle mutations; the broader profile above produced 21. Operator selection materially changes what the matrix can establish.

## Interpret the evidence

Inspect both `summary` and `matrix` in the JSON report. Require nonempty attempted mutations, the intended test files, complete matrix rows, and no infrastructure errors or timeouts before making a deletion decision. `matrix.complete` covers recorded rows; it does not establish coverage of mutations excluded as `no_coverage`, `uncapturable`, `unplaceable`, or `ran_at_load`. Investigate and record those separately. Raising a timeout can resolve an incomplete row; excluding the row cannot prove redundancy.

| Result | Review action |
| --- | --- |
| Surviving mutation changes observable behavior | Strengthen the existing assertion or add a focused test of that behavior. |
| Surviving mutation preserves behavior for supported callers | Record the equivalence and its scope; retain the raw result unless a reviewed suppression is justified. |
| Mutation has no coverage or no usable verdict | Fix the scope or runtime problem, or record the unverified behavior. It provides no evidence for removing a test. |
| Test is marked blind | Check whether its assertions concern another source file, an unmutated literal, an integration, or an error path outside this fault model. |
| Test is marked redundant | Compare its behavioral purpose and assertions with its other killers. Retain distinct guarantees; consolidate only demonstrated duplication. |

Read the failing assertions and error paths where necessary. Multiple tests can kill a mutation because it breaks common setup or raises an incidental exception. That overlap alone does not show that their intended assertions protect the same behavior.

Establish a valid control before checking a rejection. During this audit, the stance reason-length examples supplied no ballot choices, so they remained invalid when the reason validator was removed. Valid ballots with explicit HTML input now check the accepted 500-character boundary, rejection at 501, the disabled limit and drafts. The separate emoji example checks UTF-16 length, which is a different guarantee even when both examples kill removal of the same validator. Keep it when the selected mutation profile does not reach the shared length calculation.

Keep unrelated failure gates open when checking a guard. The chatbot duplicate-delivery example originally made its second call after the DNS stub ended; a failed fetch could hide removal of duplicate suppression. Both calls now use the same valid destination. Similarly, test realtime destinations through the actual publishing method and intercept the broadcast transport, so deleting that publishing method cannot leave a test passing against its own stub.

A useful test need not be the only killer of a generated mutant. Conversely, a test can appear uniquely useful because the selected test set omits its real replacement. Preserve the reasoning about Loomio's behavior alongside the matrix evidence.

## Change one candidate and verify it

1. For a real gap, test the observable outcome. Prefer strengthening a weak existing example over adding a near duplicate. Do not introduce an implementation-specific assertion solely to change a score.
2. For demonstrated duplication, consolidate one candidate into its replacement at a time. Preserve useful inputs and assertions. Two individually redundant tests can be each other's only replacement; deleting a batch can lose their shared kills.
3. Re-run the selected tests and the same full-source matrix, using the same tool version and operators. Compare mutant IDs and verdicts: every previously killed mutation must still be killed. A stable percentage can hide one lost kill and one new kill, and an uncovered mutation can disappear from the score.
4. Re-run the relevant integration tests, including controller, worker, serializer, and access-control tests where the service crosses those boundaries. Check in-memory state as well as persisted state when a caller serializes the object without reloading it.
5. Record tests consolidated, assertions strengthened, exact retained and newly caught mutant IDs, remaining survivors and coverage gaps, matrix completeness, runtime, and the integration test result. Keep each cleanup independently reviewable.

Keep failures visible. The tool's exit code can be zero with survivors when no threshold is configured; read the report. Review equivalent survivors rather than adding artificial tests or broad suppressions to force a perfect score.

## Pilot results

The October 2026 pilot applied the broader profile above independently to each service. Each after run had complete rows, zero errors, zero timeouts, the same candidate mutation IDs as its before run, and no lost kills. Times are local wall-clock measurements including Rails boot and coverage capture; they are not CI benchmarks.

The [pilot evidence](mutation_testing_pilot.json) records the source revision, operator profile, exact candidate and killed IDs, remaining survivor diffs, and uncovered mutation. Combined service, controller, membership, access-control, push-delivery, and boot regressions passed: 222 tests, 913 assertions, zero failures or errors.

| Service | Tests before → after | Mutations caught before → after | After runtime |
| --- | --- | --- | --- |
| ThrottleService | 10 → 9 | 21/21 → 21/21 | 21.24 s |
| TurnstileService | 7 → 9 | 26/34 → 30/34 | 29.01 s |
| WebPushService | 3 → 5 | 7/10 → 10/10 | 13.54 s |

Throttle reset examples were consolidated while retaining both string and symbol periods. An assertion about the namespace's UUID shape was removed with the overlapping example; the retained test verifies that resetting a used bucket restores its allowance. Tests for counter boundaries, increment size, bucket isolation, per-minute limits, and environment overrides remain despite matrix overlap because those are distinct guarantees.

Turnstile's HTTP-error test originally used an empty response body. Removing the HTTP-status guard still failed JSON parsing and returned a falsey result, so the test did not prove that status was checked. Its replacement uses an HTTP error with a successful-looking body. Additional tests check both request timeouts and preservation of the verification token across a supported redirect. Configuration and direct-success tests remain despite overlap because they cover whitespace handling and forwarding the remote IP.

Turnstile retains three survivors: two replace a false return with nil, which its current conditional callers treat identically; one changes authorization-header clearing on redirects, while this connection sends no authorization header. These are scoped observations, not proof that all future callers or connection configurations are equivalent. One mutation in the public site-key accessor remains uncovered by this service test set. Scores exclude that uncovered mutation.

Web Push tests now exercise missing VAPID settings and prevent delivery with incomplete configuration. The successful-delivery example checks the payload and credentials passed to the sender, resets a nonzero failure count, and advances an old last-seen timestamp. It remains valuable even when the chosen mutation profile labels it redundant. The selected operators do not exercise every possible payload-field or persistence mistake.

The pilot found seven additional caught mutations while consolidating one test. Total tests increased from 20 to 23 as missing behavior was covered. It established no CI speedup and makes no claim that a smaller test count is intrinsically better.

## Regular use across Loomio

Adopt targeted audits during substantive Ruby service or test changes and staged maintenance sweeps. Keep ordinary regression tests as the primary development check. Full-source kill matrices are appropriate for cleanup; diff-scoped mutation runs can provide additional feedback on changed implementation code after scope is checked.

For comprehensive coverage, maintain an inventory of service sources, their relevant test files, last audited revision, operators, remaining gaps, and next review reason. Work through the inventory one service or cohesive component at a time. Include related controller, worker, serializer, and model tests when they protect a distinct contract. Revisit a completed entry when its implementation, callers, access boundaries, test coverage, or mutation-tool version changes.

A proposed cadence is a bounded weekly maintenance batch, with a quarterly review of inventory entries not touched by ordinary development. Record each batch's scope and cost. This is a proposed operating cadence; no scheduled job or recurring automation is installed by this guidance.

Measure larger components before adding a full-repository gate. Matrix cost grows with the number of attempted mutants and the cost of running every covering test for each one, plus boot and coverage capture. Database fixture work and integration-heavy services can dominate. Three small service runs do not establish the cost of the whole application. Start any CI rollout as a visible, scoped report; choose gating and runtime budgets only after enough representative measurements.

Loomio's JavaScript/Vue tests require their own mutation tooling and trial. A Ruby service inventory does not cover frontend behavior. Security review, the access-control fixture matrix, concurrency tests, and end-to-end workflows continue to cover faults that this operator catalogue cannot establish.

## Comprehensive audit

The [audit plan](mutation_audit_plan.json) maps every model, controller, and service test file to the implementation it exercises. Additional contexts track ability modules, shared authorization and session helpers, channels, queries, serializers, workers, integration tests, mail, exports, and historical security migrations. Keep this mapping curated: an absent paired filename does not mean a test has no implementation, and a passing test can exercise behavior outside the file being mutated.

Identical source sets use one full-source matrix containing the union of their test files. This avoids repeating source experiments and provides cross-file kill information. Per-file workflows, performance assertions and access boundaries retain their own behavioral review; sharing a source does not make their tests interchangeable.

The [measurement ledger](mutation_audit_progress.json) and [behavioral review ledger](mutation_audit_reviews.json) deliberately track different work. The [exact kill-preservation comparisons](mutation_audit_preservation.json), [regression results](mutation_audit_validation.json), [security review](mutation_audit_security_review.md) and [confirmed findings](mutation_audit_findings.json) preserve validation and unresolved application work separately. A measured context still needs behavioral review. Review entries record exact mutation IDs, scoped equivalences, missing coverage, and preservation of earlier kills when tests change. Do not interpret pending, interrupted, incomplete, uncovered, or external-dependency contexts as completed coverage.

Source mappings follow the operation under test. Account-history tests retire accounts through the deactivation/redaction workers; services that only create fixture polls or cast the initial votes do not replace those worker profiles. All eight cleanup test files share one full-source cleanup matrix, with the delivery-audience test also included in the notification router matrix. These are grouped experiments, not removed or consolidated test cases. The [scope-change ledger](mutation_audit_scope_changes.json) records the initial inventory reduction from 314 to 280 contexts, the added shared instance-administrator boundary (281 contexts), and every retained test file.

Membership-request notification cases similarly belong with the request lifecycle and its kind-specific delivery/name routers. Mutating a full poll-building service used only for setup inflated the inferred source set while omitting those routers. Existing request-controller tests also cover service authorization and persisted ignored responses; include those callers before writing equivalent service cases. Keep historical candidate sets distinct when correcting a source mapping rather than presenting their different totals as a coverage improvement.

The [runtime-limit review](mutation_audit_runtime_limits.json) separates a hanging test parser from operator-induced nontermination and unresolved fork/runtime behavior. The BLT format test now asserts its ballot terminator before taking a bounded slice, so a missing terminator produces a failed assertion. Other mutations can remove a dependency walk's termination condition or make channel publication recursive. Keep their raw timeout/incomplete verdicts and investigate the cause before repeating a costly profile; neither a larger timeout nor a previously caught partial row establishes a complete kill matrix or permits removing tests.

Set a matrix timeout for the complete covering test set, not just the first failing example. When the unchanged selected baseline itself exceeds that allowance, preserve the partial report and retry with a documented, bounded context-specific budget. The expanded Topic baseline passed 179 tests in 50.85 seconds, exceeding its old 30-second allowance; its 21 timeouts and 15 partially killed rows require a larger-budget retry before completion. This differs from a diagnosed loop whose termination condition was removed.

That review also records a test-selection limit in the mobile consent controller. Ruby 4.0.5 gives its continued boolean statements one line event, while Mutineer 1.6.0 conservatively avoids borrowing that event for a later short-circuit operand. Valid and invalid protocol requests exercise the behavior, but six comparison operators still receive no selected tests. Keep those `no_coverage` verdicts, the compiler evidence and the behavior checks; adding more copies of the same requests cannot establish a missing mutation verdict. The same bytecode and pinned selector probe identifies the continued trial-plan comparison in `GroupPrivacy`; that limitation does not establish whether every trial/privacy combination has a behavioral regression.

Check the mutation's application point for methods that generate other methods. Loomio eagerly loads its test environment, and `HasRichText.is_rich_text` registers per-model methods and callbacks during that boot. The pinned Rails redefine strategy replaces the enclosing macro method after boot, so it does not rebuild those already registered callbacks. Executed callback lines can therefore appear beside surviving macro-body mutations that never changed the callback used by the test. Keep generated-behavior checks and review that part structurally or with a suitable boot-aware experiment; assess ordinary runtime helper gaps separately.

`--limit N` bounds new measurement attempts; reusable complete results do not consume the batch allowance, so recurring bounded runs advance through the queue. Failed baselines and incomplete attempts still consume an attempt and remain explicitly unfinished.

The runner resumes measurements whose content signatures match the Ruby version, application/library/configuration Ruby files, schema, lockfile, shared fixtures, support files, selected tests, source mapping, and tool version. Non-Ruby application/configuration files and process environment values are not part of that shared fingerprint unless explicitly selected. Review changes to those inputs before reusing results; the current audit holds application and configuration files fixed throughout. It runs a green selected-test baseline before a new matrix, saves each signature's reports under `tmp/mutation_audit/`, and rejects reuse after relevant inputs change. Historical migration contexts load their migration classes before fork capture. An exclusive lock prevents two audit runners in the same checkout; it cannot prevent someone separately launching Rails or E2E tests, so coordinate those runs.

Aggregate review signatures also include the sources, test files and mappings of their declared `covered_by` contexts. A later change to one permission module's caller tests must invalidate the aggregate review even when its own general ability test file is unchanged. Review each complete module result and its access boundaries separately; this dependency tracking does not turn separate module matrices into one global matrix.

```sh
bundle exec ruby script/mutation_audit.rb status
bundle exec ruby script/mutation_audit.rb run \
  --tool tmp/mutineer/gems/gems/mutineer-1.6.0/bin/mutineer

# A bounded batch, or a specific context, uses the same signature checks.
bundle exec ruby script/mutation_audit.rb run \
  --tool tmp/mutineer/gems/gems/mutineer-1.6.0/bin/mutineer \
  --only permissions/ --limit 3
```

`status` revalidates content signatures when its Mutineer executable is available; otherwise it labels its counts as recorded states. Pass `--tool PATH` when the executable is installed outside the default temporary location. It also flags newly added model, controller, or service tests missing from the plan. `run` revalidates signatures and requires the saved report before reusing results. `status` labels a missing local report as `report_missing`; copying a ledger without its temporary artifacts cannot establish a reusable matrix. Keep the source inventory and review evidence when making test changes; raw reports are local temporary artifacts. Review stale evidence again before using it to justify a deletion.

Large sweeps can use `--partition 0/3`, `--partition 1/3`, and `--partition 2/3` in three separate checkouts with identical application/test inputs and distinct test databases. Assignment uses a stable hash of each context ID; adding an inventory entry does not move other contexts between partitions. Each checkout still runs one matrix at a time. Verify database URLs before preparing or running each partition, and copy later test fixes into the relevant checkout before resuming it. Never point two partitions at the same database. If a separate checkout is already measuring a specific context, use repeatable `--exclude-id ID` options to defer those exact IDs in the bulk partition and avoid duplicate work. For a batch of exact contexts, repeat `--only-id ID`; the existing `--only TEXT` option matches substrings and can select adjacent context names. Excluded contexts retain their recorded state and still require a complete measurement and review; an exclusion is not a completion verdict.

Stop the primary checkout's runner before importing partition results with `merge --tool PATH --from CHECKOUT` (repeat `--from` for more checkouts). The merger takes the same exclusive lock, checks each result's signature against the primary checkout's current inputs, and copies its reports and baseline log. It imports complete measurements, explicit unexercised results and incomplete attempts; incomplete attempts never replace a complete matching result and must be rerun before they can support a deletion. Results from older snapshots remain unverified until rerun. `SIGUSR1` requests a pause after the current context; interrupting with `SIGINT` records an interrupted measurement that must be rerun.

The general ability suite is represented by an umbrella review of the 25 permission-module matrices. Its sources and tests are already included in those contexts; repeat measurement is unnecessary. This is a dependency-based review, not a global complete kill matrix across every selected permission test, and it does not authorize batch deletion.

The initial complete Rails baseline in the isolated October 2026 audit checkout passed with 3,154 tests and 29,767 assertions, zero failures or errors, and two existing skips: the optional OpenTally comparison and disabled slow chatbot previews. Four billing-engine controller suites are conditional on the absent optional LoomioSubs engine. They require that engine's test environment before they can be measured; their absence is not evidence for removing them.

The login-token service review consolidated five tests to four after moving the stored redirect assertion into the creation example. The retained example checks both the returned redirect and `token.reload.redirect`: an in-memory value alone does not prove persistence. The full matrix retained all 12 candidate IDs and all 11 earlier kills, with complete rows and no errors or timeouts. Mail delivery, logged-out refusal and foreign-host redirect rejection remain separate. The event-bus publication is still an unasserted survivor. Exact before/after evidence is recorded with the regression results.

Foreign keys, not-null constraints, cascades, SQL text, declarative validations, and declarations loaded at boot can be outside this method mutation profile. Preserve their application-specific regression assertions and review the storage or initialization contract directly. Likewise, removing an ability module's `super` call can break many unrelated permission tests through shared initialization; those common kills cannot justify dropping their individual roles or workflows.

## Sources

- [Stephen Margheim's discussion of the kill matrix](https://www.youtube.com/watch?v=OmrdvAzCSIc&t=2304s).
- [Mutineer kill-matrix documentation](https://github.com/davidteren/mutineer#kill-matrix); check the installed version's README and CLI before running commands.
