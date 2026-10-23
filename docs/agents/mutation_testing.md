# Reviewing Ruby tests with mutation testing

Use Mutineer's kill matrix to find missing behavioral checks and review overlapping model, controller, service, and permission tests. Start with one component, keep production code fixed while comparing tests, and record the useful results in the pull request. Mutation scores alone do not establish that a test is unnecessary.

## Ongoing workflow

Run focused mutation checks when adding or changing tests or making substantive changes to Ruby behavior. Select the production methods or components affected by the change and include their relevant model, controller, service, permission, serialization, rendering, and integration tests. Read the callers to choose that scope; a component's paired test file may cover only part of its behavior. Continue to run ordinary regression tests as usual.

Use Mutineer directly with the selected sources and tests. Keep any temporary inventories, batch scripts, reports, caches, and installed tooling under ignored `tmp/`. A repository-wide audit can use a temporary queue to organize the work; retire that queue and its batch runner once the review is complete and any execution limits have been addressed or explicitly accepted. Keep the improved tests and these instructions in version control. There is no permanent audit inventory to maintain or requirement to repeat the whole repository audit for each change.

The initial repository-wide audit reviewed all 281 original contexts, including 255 complete mutation matrices. Its 12 runtime-limited and four optional billing-engine execution limits were explicitly accepted on 23 October 2026; the remaining contexts had structural or aggregate reviews. That completes the initial review with those limits, without claiming full mutation execution or coverage. The historical completion record remains available in Git at `025a812904^:agents/mutation_audit_completion.json`. Later code changes require their own focused evidence.

## Review a component

1. Read the implementation, its callers, and all relevant tests. Identify the behaviors, side effects, error paths, boundary values, and historical regressions they protect. Run the selected tests against the unmodified implementation first.
2. Record the Mutineer version and operator list. Use the full selected source for test cleanup: `--since` can omit behavior protected by an overlapping test.
3. Require nonempty attempted mutations, the intended test files, complete matrix rows, and no infrastructure errors or timeouts before considering a deletion. Investigate uncovered, uncapturable, and boot-time behavior separately.
4. Read the assertions and failure paths. Shared kills can result from broken setup or incidental exceptions. Establish valid controls for rejection tests so unrelated failures cannot hide removal of the guard being tested.
5. Strengthen observable outcomes for real gaps. Consolidate only demonstrated duplication, one candidate at a time. Preserve distinct roles, workflows, privacy modes, integrations, and persistence guarantees even when their tests share kills.
6. Re-run the selected tests and the same full-source matrix. Compare exact mutant IDs and verdicts; every previously caught mutation must remain caught. A stable percentage can hide lost detections. Run related integration regressions where boundaries cross components.
7. Summarize the changes, preserved guarantees, remaining survivors and coverage gaps, matrix completeness, runtime, and regression results in the pull request. Keep generated JSON, detailed review records, and logs under ignored `tmp/`.

For voting, anonymous polls, permissions, authentication, and sessions, follow the [security-review instructions](security.md) and retain the reusable access-control fixture matrix. A complete mutation matrix does not replace direct security review. Constraints, SQL, declarative validations, callbacks registered at boot, concurrency, and generated methods can require structural review or other experiments.

## Run a kill matrix

Use Mutineer 1.6.0. Install it into the checkout's ignored temporary directory without changing application dependencies:

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

Repeat `--test` for additional relevant files. Use separate before/after report names and separate cache directories for independent audits. Read the JSON summary and matrix even when the tool exits successfully; a zero exit code can include survivors.

Use `--only 'Poll#quorum_count'` to restrict a run to a complete method when that is the intended scope. For scope and filter behavior, consider adding the `chain_link` operator so the audit tests removal of calls such as `latest` or `decided`. Record the chosen methods, tests, and operators with the results. Frontend tests require their own mutation tooling.

Use the checkout's configured Ruby and test database, and follow the [test instructions](testing.md). Linked worktrees derive their own database name through `TestDatabaseUrl` unless `DATABASE_URL` or `TEST_DATABASE_URL` overrides it. On the macOS audit setup, forked PostgreSQL connections required `PGGSSENCMODE=disable`; investigate capture failures before interpreting results. Mutineer 1.6.0 matrix runs use the serial in-process backend and cannot combine `--matrix` with `--daemon`, `--test-command`, or `--fail-fast`.

## Interpret and retain results

Aim to detect mutations that change intended behavior. A raw 100 percent score is not required: equivalent mutations, tool limits, and behavior outside the selected test scope need explicit review. Add behavioral assertions for genuine gaps in the changed behavior. Do not suppress survivors or invent unsupported input states merely to increase the score. Document remaining limits and distinguish accepted limits from complete execution.

Results apply to the source, tests, dependencies, fixtures, configuration, and tool version used for the run. Record enough information to identify those inputs and compare exact mutant IDs before and after test changes. Recheck relevant changes before reusing old reports or caches; a completed historical audit does not establish current coverage.

Matrix cost grows with candidate count, covering test work, and boot/capture overhead. Run one component at a time, set timeouts above its clean test baseline, and investigate nontermination. If a run is interrupted, stop its child processes before another suite uses the same database. Separate checkouts with distinct test databases are required for parallel audit work. Increasing a timeout alone is not evidence for deleting a test.
