# Agent Instructions

## Always apply

- Use **group admin** and **thread admin** for Loomio's permission roles. **Administrator** is also acceptable; never call these roles **coordinator**. Follow `config/locales/glossary.yml` for translations, including when legacy identifiers contain `coordinator`.
- Do not run `git commit` unless the user explicitly asks for a specific commit. Permission to commit once does not authorize a later commit, including after more work is requested.
- Do not self-reference or market the agent in branch names, commit messages, PR titles, PR descriptions, or other project-facing metadata.
- Boolean env vars: **presence is truthy**. Set the var to enable, omit it to disable. Check with `ENV["VAR"].present?` (Rails) or `ENV.key?("VAR")` (plain Ruby) — never compare against `"true"` or `"1"`.
- Run Rails tests with escalated sandbox permissions on the first attempt; the local PostgreSQL test database is not reachable from the filesystem sandbox. Use the existing approved `bin/rails test` permission.
- Never run Rails tests and E2E tests in parallel. Run one suite at a time because they can share the test database.
- Changes touching voting, anonymous polls, permissions, authentication, or sessions require an explicit security review and focused regression tests. Read the security instructions below before working on these areas.
- For user-visible features and behaviour changes, read the user-manual instructions below and update relevant documentation.
- Do not hard-wrap prose in Markdown documents. Keep each paragraph and list item on one source line; preserve deliberate line breaks required by Markdown syntax or the content.

## Read the instructions for your task

Before starting an applicable task, read every matching document below. These are required instructions, not optional background. Read additional documents when the scope expands. Paths in these documents are relative to the repository root unless a Markdown link specifies otherwise.

| Task | Required instructions |
| --- | --- |
| Writing, changing, or reviewing application code | [Code style and domain invariants](docs/agents/code_style.md) |
| Branches, commits, attribution, or pull requests | [Git and pull requests](docs/agents/git_workflow.md) |
| Voting, anonymous polls, permissions, authentication, sessions, or security review | [Security review](docs/agents/security.md) |
| User-facing copy, documentation, changelog entries, emails, or onboarding text | [Writing and Markdown](docs/agents/writing.md) |
| Application strings, translations, terminology, or glossary changes | [Localization](docs/agents/localization.md) |
| Frontend or Vue work | [Frontend and Vue](docs/agents/frontend.md) |
| Adding, changing, running, or debugging tests; mutation audits or test-suite cleanup | [Tests](docs/agents/testing.md) |
| User-visible features or behaviour changes; user manual, guides, API reference, help-site builder, navigation, links, or redirects | [User manual and help site](docs/agents/user_manual.md) |
| Manual translations or translation tooling; preparing a feature for merge | [User-manual translations](docs/agents/user_manual_translations.md), alongside the user-manual instructions |
| Manual screenshots; preparing a feature for merge | [User-manual screenshots](docs/agents/user_manual_screenshots.md), alongside the user-manual instructions |
| Release notes, version bumps, release tags, publishing releases, or deployment as part of a release | [Release notes](docs/agents/release_notes.md) |

## Sentry

Loomio uses the configured Sentry MCP connection for the self-hosted instance at `https://bugs.loomio.com` (organization slug: `loomio`). Use its Sentry tools to inspect or manage issues; do not use the generic Sentry CLI unless specifically asked.
