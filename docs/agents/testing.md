# Test instructions

## Running Tests

**Run Rails tests with escalated sandbox permissions on the first attempt.** The local PostgreSQL test database is not reachable from the filesystem sandbox. Use the existing approved `bin/rails test` permission instead of first running the command in the sandbox and reporting the predictable connection failure.

**Do not add tests that only restate documented Rails behaviour.** These tests do not establish the correctness of Loomio's application behaviour. Test the Loomio-specific invariant, integration, or user-visible outcome instead.

**Never run Rails tests and E2E tests in parallel.** Both use the `loomio_test` database (via `RAILS_ENV=test`) and will corrupt each other's data if run concurrently. Run one suite at a time.

For database migrations, prioritize focused regression tests and realistic-data rehearsals of query plans, concurrent reads and writes, transaction rollback, and restart behavior. Mutation testing does not establish that SQL scales or locks remain short.

## Running E2E Tests

E2E tests use Nightwatch + headless Chrome against a local Rails server.

### Prerequisites
- If you get schema related errors it might help to run `dropdb loomio_test; RAILS_ENV=test rake db:setup`

### Using `bin/e2e`

```bash
bin/e2e                                    # run all specs
bin/e2e notifications.js                   # run one spec file (shorthand)
bin/e2e vue/tests/e2e/specs/poll.js        # run one spec file (full path)
bin/e2e notifications.js --testcase has_all_the_notifications  # run one test
bin/e2e notifications.js --retries 3       # retry failures
```

The script handles: Vue build, db:prepare, starting/stopping the Rails server, and running Nightwatch headlessly.

Always let `bin/e2e` build Vue assets. The build is fast, and running against freshly built assets avoids stale-client failures.

Use `--testcase <name>` to run a single test within a file. This is much faster for confirming fixes.

### How it works

1. Dev scenarios in `app/controllers/dev/` and `app/helpers/dev/` set up test data
2. Nightwatch specs in `vue/tests/e2e/specs/` drive the browser via `pageHelper`
3. `pageHelper.loadPath('scenario_name')` hits `http://localhost:3000/dev/scenario_name`
4. The Rails server runs in test mode with `RAILS_ENV=test`

### Fixing test failures

- **"element not interactable" / "click intercepted"**: Usually a z-index or overlay issue. These often pass on retry (`--retries 3`).
- **"Timed out waiting for .app-is-booted"**: The dev scenario errored. Check Rails server logs for the exception (e.g., `NoMethodError`, `Deadlocked`).
- **"Expected text to contain X"**: The dev scenario isn't producing the expected data. Check the scenario in `app/helpers/dev/ninties_movies_helper.rb` or `app/helpers/dev/scenarios_helper.rb`.
- Screenshots on failure are saved to `vue/tests/screenshots/`.

### Key files

- `bin/e2e` — test runner script
- `vue/nightwatch.conf.js` — Nightwatch configuration
- `vue/tests/e2e/specs/` — test specs
- `vue/tests/e2e/helpers/pageHelper.js` — shared browser helpers
- `app/controllers/dev/` — dev scenario routes
- `app/helpers/dev/ninties_movies_helper.rb` — main scenario data builder
- `app/helpers/dev/scenarios_helper.rb` — additional scenario helpers

## Mutation testing

Run Mutineer only when explicitly requested or as part of removing or consolidating Ruby tests. It is not required for routine fixes, features, adding or editing tests, migrations, or dependency updates. Skipping it during ordinary development does not require approval.

Use the kill matrix to answer a specific question about missing behavioral checks or overlapping tests. Start with one component and set a time budget before running it. Keep production code fixed while comparing tests. Do not automatically expand the scope, chase a score, or keep retrying tooling failures. When the budget is reached, stop and report survivors, incomplete coverage, and tooling limits without asking for approval to leave them unresolved. If the evidence is insufficient to justify removing a test, retain it and continue the other work.

### Review a component

1. Read the implementation, callers, and relevant tests. Identify the behaviors, side effects, error paths, boundaries, and historical regressions they protect. Include relevant integration callers when selecting tests, and run the selected regression tests first.
2. Record the Mutineer version, operators, selected sources and tests, and time budget. For test removal or consolidation, use the full selected methods or component: `--since` can omit behavior protected by overlapping tests.
3. Before using a matrix to justify a deletion, require nonempty attempted mutations, the intended test files, complete matrix rows, and no infrastructure errors or timeouts. Report uncovered, uncapturable, and boot-time behavior separately.
4. Read assertions and failure paths. Shared kills can result from broken setup or incidental exceptions. Establish valid controls for rejection tests so unrelated failures cannot hide removal of the guard being tested. Mutation scores alone do not establish that a test is unnecessary.
5. Strengthen observable outcomes for real gaps. Consolidate only demonstrated duplication, one candidate at a time. Preserve distinct roles, workflows, privacy modes, integrations, and persistence guarantees even when tests share kills.
6. After removing or consolidating tests, re-run the selected regressions and the same full-source matrix within the audit budget. Compare exact mutant IDs and verdicts; every previously caught mutation must remain caught. A stable percentage can hide lost detections. If verification cannot be completed, retain the tests being considered for removal.
7. Summarize useful results, preserved guarantees, remaining survivors and coverage gaps, matrix completeness, runtime, and regression results in the pull request. Keep temporary inventories, tooling, reports, and caches under ignored `tmp/`; no permanent repository-wide inventory is required.

For voting, anonymous polls, permissions, authentication, and sessions, follow the [security-review instructions](security.md) and retain the reusable access-control fixture matrix. A complete mutation matrix does not replace direct security review. Constraints, SQL, declarative validations, callbacks registered at boot, concurrency, and generated methods can require structural review or other experiments.

### Run a kill matrix

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

Repeat `--test` for additional relevant files. Use separate before/after report names and separate cache directories for independent audits. Read the JSON summary and matrix even when the tool exits successfully; a zero exit code can include survivors. `--timeout` limits each mutant, not the whole audit; enforce the overall time budget separately.

Use `--only 'Poll#quorum_count'` to restrict a run to a complete method when that is the intended scope. For scope and filter behavior, consider adding the `chain_link` operator so the audit tests removal of calls such as `latest` or `decided`. Record the chosen methods and operators with the results. Frontend tests require their own mutation tooling when a frontend mutation audit is requested.

Use the checkout's configured Ruby and test database. Linked worktrees derive their own database name through `TestDatabaseUrl` unless `DATABASE_URL` or `TEST_DATABASE_URL` overrides it. On the macOS audit setup, forked PostgreSQL connections required `PGGSSENCMODE=disable`; capture failures invalidate the affected results. Mutineer 1.6.0 matrix runs use the serial in-process backend and cannot combine `--matrix` with `--daemon`, `--test-command`, or `--fail-fast`.

### Interpret results and stop

Aim to detect mutations that change intended behavior. A raw 100 percent score is not required: review equivalent mutations, tool limits, and behavior outside the selected scope, then report remaining limits. Do not suppress survivors, invent unsupported input states, or automatically add further runs merely to increase the score. Distinguish accepted limits from complete execution.

Results apply to the source, tests, dependencies, fixtures, configuration, and tool version used for the run. Record enough information to identify those inputs and compare exact mutant IDs before and after test changes. Recheck relevant changes before reusing old reports or caches; a completed historical audit does not establish current coverage or require mutation testing for subsequent routine work.

Matrix cost grows with candidate count, covering test work, and boot/capture overhead. Run one component at a time and set per-mutant timeouts above its clean test baseline. Stop a stalled or over-budget run and its child processes before another suite uses the same database. Separate checkouts with distinct test databases are required for parallel audit work. Increasing a timeout alone is not evidence for deleting a test.

The initial repository-wide audit reviewed all 281 original contexts, including 255 complete mutation matrices. Its 12 runtime-limited and four optional billing-engine execution limits were explicitly accepted on 23 October 2026; the remaining contexts had structural or aggregate reviews. The historical completion record remains available in Git at `025a812904^:agents/mutation_audit_completion.json`. There is no requirement to repeat that audit for each change.
