# Agent Instructions

## Project overview and commands

Loomio is a Rails backend (`app/`, `db/`, `test/`) with a Vue 3 + Vuetify frontend (`vue/`) backed by PostgreSQL.

- **Rails tests:** `bin/rails test <path>`
- **Vue tests:** `(cd vue && npm run test:unit)` and `(cd vue && npm run test:component)`
- **E2E tests:** `bin/e2e <spec>` (Playwright; never run in parallel with Rails tests because they share `loomio_test`)

## Always apply

- Use **group admin** and **thread admin** for Loomio's permission roles. **Administrator** is also acceptable; never call these roles **coordinator**. Follow `config/locales/glossary.yml` for translations, including when legacy identifiers contain `coordinator`.
- Commit only when requested, except for an authorized deployment (which includes committing and pushing source before building or deploying, unless told to review first or withhold a push).
- Do not self-reference or market the agent in branch names, commit messages, PR titles, PR descriptions, or other project-facing metadata.
- Prefix every new environment variable with `LOOMIO_` and preserve existing names unless a rename is explicitly requested. For boolean env vars, **a non-empty value is truthy**: set a value to enable, omit or leave empty to disable, and check with `ENV["VAR"].present?` rather than comparing against `"true"` or `"1"`.
- Changes touching voting, anonymous polls, permissions, authentication, or sessions require an explicit security review and focused regression tests; read [Security review](docs/agents/security.md) before starting.
- For user-visible features or behaviour changes, update the user manual, get user approval of the English changes before translating, and complete translations before opening a pull request; read [User manual and help site](docs/agents/user_manual.md).
- Record lasting lessons for agents in these instructions, not in an agent's private memory, so every tool and contributor sees them. Put task-specific lessons in the matching `docs/agents/*.md` file and add to `AGENTS.md` only when a rule applies across all tasks.

## Read the instructions for your task

Before starting an applicable task, read every matching document below. These are required instructions, not optional background. Read additional documents when the scope expands. Paths in these documents are relative to the repository root unless a Markdown link specifies otherwise.

| Task | Required instructions |
| --- | --- |
| Writing, changing, or reviewing application code or database schema/migrations (`app/`, `db/`, `lib/`) | [Code style and domain invariants](docs/agents/code_style.md) |
| Branches, commits, attribution, or pull requests | [Git and pull requests](docs/agents/git_workflow.md) |
| Voting, anonymous polls, permissions, authentication, sessions, or security review (`app/policies/`, polls, auth) | [Security review](docs/agents/security.md) |
| User-facing copy, Markdown documents, changelog entries, emails, or onboarding text | [Writing and Markdown](docs/agents/writing.md) |
| Application strings, translations, terminology, or glossary changes (`config/locales/`) | [Localization](docs/agents/localization.md) |
| Frontend or Vue work (`vue/`) | [Frontend and Vue](docs/agents/frontend.md) |
| Adding, changing, running, or debugging tests; mutation audits or test-suite cleanup (`test/`, `vue/tests/`) | [Tests](docs/agents/testing.md) |
| User-visible features or behaviour changes; user manual, guides, API reference, help-site builder, navigation, links, or redirects (`docs/help/`) | [User manual and help site](docs/agents/user_manual.md) |
| Manual translations or translation tooling; preparing a PR or merge for user-visible or manual changes | [User-manual translations](docs/agents/user_manual_translations.md), alongside the user-manual instructions |
| Manual screenshots; preparing a user-visible feature for merge | [User-manual screenshots](docs/agents/user_manual_screenshots.md), alongside the user-manual instructions |
| Release notes, version bumps, release tags, publishing releases, or deployment as part of a release | [Release notes](docs/agents/release_notes.md) |

## Environment and tooling

- **Rails test sandbox:** Run `bin/rails test` with escalated sandbox permissions on the first attempt using the existing approved permission; the local PostgreSQL test database is not reachable from the filesystem sandbox.
- **Sentry:** Loomio uses the configured Sentry MCP connection for the self-hosted instance at `https://bugs.loomio.com` (organization slug: `loomio`). Use its Sentry tools to inspect or manage issues; do not use the generic Sentry CLI unless specifically asked.
