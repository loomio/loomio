# Reviewing Ruby tests with mutation testing

Use Mutineer's kill matrix to find missing behavioral checks and review overlapping model, controller, service, and permission tests. Start with one component, keep production code fixed while comparing tests, and record the useful results in the pull request. Mutation scores alone do not establish that a test is unnecessary.

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

The runner uses Mutineer 1.6.0. Install it into the checkout's ignored temporary directory without changing application dependencies:

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

Use the checkout's configured Ruby and test database, and follow the [test instructions](testing.md). Linked worktrees derive their own database name through `TestDatabaseUrl` unless `DATABASE_URL` or `TEST_DATABASE_URL` overrides it. On the macOS audit setup, forked PostgreSQL connections required `PGGSSENCMODE=disable`; investigate capture failures before interpreting results. Mutineer 1.6.0 matrix runs use the serial in-process backend and cannot combine `--matrix` with `--daemon`, `--test-command`, or `--fail-fast`.

## Run bounded audit batches

The reusable [audit plan](../../script/mutation_audit_plan.json) maps sources to relevant tests, including related controllers, workers, serializers, permissions, and integrations. Keep that mapping current when application boundaries or tests change. Identical source sets share a matrix containing their combined tests; their distinct behavioral guarantees still need review. Structural, optional-engine, and aggregate contexts require their declared review rather than an independent executable matrix.

```sh
bundle exec ruby script/mutation_audit.rb status
bundle exec ruby script/mutation_audit.rb run \
  --tool tmp/mutineer/gems/gems/mutineer-1.6.0/bin/mutineer \
  --only permissions/ --limit 3
```

Progress, optional manual reviews, reports, and baseline logs live under ignored `tmp/mutation_audit/`. The runner reads `progress.json` and, when present, `reviews.json` there. They are local run state, never repository instructions or committed audit history. A fresh checkout starts with no recorded measurements; retaining a plan does not establish current coverage.

`--limit N` bounds new measurement attempts, including failed baselines and incomplete attempts. Complete reusable results do not consume that allowance. Use repeatable `--only-id ID` or `--exclude-id ID` for exact contexts; `--only TEXT` matches substrings. Excluding a context leaves it unfinished. Set each timeout above its complete selected baseline, investigate nontermination, and retain incomplete verdicts. Increasing a timeout alone is not deletion evidence.

The runner fingerprints Ruby, the tool, application/library/configuration Ruby files, view templates, locale files, schema, lockfile, fixtures, test support, selected inputs, and aggregate dependency mappings. Non-Ruby configuration and environment values are not included unless explicitly selected; review those changes before reuse. `status` revalidates fingerprints when the tool is available, flags newly unmapped model/controller/service tests, and reports missing local artifacts. `run` requires a green baseline and unchanged inputs before accepting a matrix. Measurement and behavioral review remain separate.

For partitioned sweeps, use `--partition 0/3`, `--partition 1/3`, and `--partition 2/3` in separate checkouts with identical inputs and distinct databases. Stop the destination runner before importing with `merge --tool PATH --from CHECKOUT`. Import reads the other checkout's local progress and revalidates signatures before copying artifacts; incomplete imports cannot replace complete matching results. `SIGUSR1` pauses after the current context; interruption or termination stops the child process group and records unfinished work. The runner lock only coordinates audit processes in that checkout, so observe the Rails/E2E database exclusion separately.

Matrix cost grows with candidate count, covering test work, and boot/capture overhead. Use targeted audits during substantive Ruby changes and bounded maintenance batches before considering a full-repository gate. No recurring automation is installed. Frontend tests require their own mutation tooling.
