# Test instructions

## Running Tests

**Run Rails tests with escalated sandbox permissions on the first attempt.** The local PostgreSQL test database is not reachable from the filesystem sandbox. Use the existing approved `bin/rails test` permission instead of first running the command in the sandbox and reporting the predictable connection failure.

**Do not add tests that only restate documented Rails behaviour.** These tests do not establish the correctness of Loomio's application behaviour. Test the Loomio-specific invariant, integration, or user-visible outcome instead.

**Never run Rails tests and E2E tests in parallel.** Both use the `loomio_test` database (via `RAILS_ENV=test`) and will corrupt each other's data if run concurrently. Run one suite at a time.

For Ruby model, controller, service, and permission changes or test-suite cleanup, follow [the mutation-testing workflow](mutation_testing.md). Use focused checks with the affected production sources and relevant tests, including integration callers. Review kill-matrix findings against the behavior each test protects, consolidate one candidate at a time, and compare exact mutant IDs before and after. Preserve security, access-control, and integration guarantees even when tests share mutation kills. Temporary audit inventories and batch tooling belong under ignored `tmp/`; no permanent repository-wide inventory is required.

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
