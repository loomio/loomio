# Release-note instructions

Read [writing.md](writing.md) before drafting release notes. Paths in these instructions are relative to the repository root unless a Markdown link specifies otherwise.

## Release notes

- Store release notes under `docs/release_notes/` using an ISO date followed by the Git tag version, for example `2026-07-22_v3.1.0.md`.
- Name the GitHub release exactly after its tag, for example `v3.1.0`. Do not prefix the release name with `Loomio`.
- Start the release-notes body with its opening paragraph. Do not add an H1 that repeats the GitHub release title.
- When drafting a release, update `lib/version.rb` to the same version number without the `v` prefix.
- Start with a paragraph describing any significant changes. Follow it with one-line summary bullets prefixed with `**Fix:**` or `**New:**`, then add detailed sections describing each change.
- Use the opening paragraph to explain generally what the release contains and its focus. Do not repeat the individual changes listed in the summary bullets.
- For every bug fix, explain what went wrong before describing the corrected behavior. Apply this to both the summary bullets and the detailed sections so readers can recognize the problem and understand the fix.
- Summarize changes that affect users, permissions, security, performance, deployment, APIs, or operator workflows. Omit routine dependency updates and purely internal refactors unless they require action or materially affect reliability.
- Link to the maintained [Upgrading guide](../../deploy/UPGRADING.md) for standard upgrade instructions. Include exact commands in release notes only when a release requires exceptional or mandatory steps beyond that guide. Still document required migrations, permission effects, compatibility notes, and links to any related security advisory or detailed feature page.
- Verify release-note claims against merged code, tests, pull requests, and user-manual changelog entries. Resolve placeholder links before publishing the release.
- Draft release notes locally and stop for the user to edit and explicitly approve them as a human check before committing the release notes, creating or pushing a tag, publishing a GitHub release, or deploying the release.
