# Agent Instructions

## Git commits

- Do not run `git commit` unless the user explicitly asks for a specific commit.

## i18n / Localization

- **Never change the value of an existing i18n key.** Existing keys may be translated into other languages; changing the English value breaks those translations.
- Instead, create a new key with the new value and update the code to reference the new key.
- **Review retranslation PRs against `config/locales/translation_corrections.md`** — that file logs sense-errors Google Translate has made before (polysemous short labels, paired actions drifting, misleading German words, glossary overrides like outcome→conclusion across many locales). If a new translation pass reintroduces one of those patterns, catch it at review.
- **When you hand-correct a translation, append it to `translation_corrections.md`** with the file, key, before/after, and a one-line "why it was wrong". The point is to accumulate the context Google doesn't have, so reviewers of the next retranslation can watch for the same traps.
- **translation keys should closely match their values** So that templates are easy to read. Rather than title, call the key what the title says.
- **Use concise language and a calm tone** For example: Don't use exclamation marks for success flash messages. Just tell the user what happened. Be aware of translation from english when writing english.. choose words with most correct meaning.

## Frontend / Vue

- Write new Vue components in `<script setup>` format — even when sibling files in the same directory still use the Options API (much of the codebase is mid-migration; don't perpetuate the old style by matching neighbours).
  - Use the `useWatchRecords` composable from `@/composables/useWatchRecords` instead of the `WatchRecords` mixin.
  - Use `LmoUrlService.route({model})` directly instead of the `UrlFor` mixin.
  - Destructure `defineProps` and reference bare prop names (not `props.x`).

## Running Tests

**Never run Rails tests and E2E tests in parallel.** Both use the `loomio_test` database (via `RAILS_ENV=test`) and will corrupt each other's data if run concurrently. Run one suite at a time.

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
