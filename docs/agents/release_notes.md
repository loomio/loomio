# Release and upgrade notes

Follow [Writing and Markdown](writing.md).

## Release notes

- Explain what changed and why it matters. Cover significant changes to user workflows, security, permissions, compatibility, performance, or deployment. Link to relevant advisories, documentation, and upgrade steps.
- Open with a short paragraph on the release’s focus, followed by one-line `**Fix:**` or `**New:**` bullets. Add detail where readers need it. For fixes, explain what went wrong before describing the correction.
- Verify claims against merged code and relevant tests or documentation. Check links before publishing.

## Upgrade notes

- Use the [upgrade guide](../../deploy/UPGRADING.md) for steps beyond the standard upgrade, such as updating an integration after a breaking change, adding a required secret, or editing a config file. Link to the guide from release notes when operators need to act.
- Omit routine migrations, automatic backfills, and other work that needs no operator action. Leave backup decisions to operators.

## Release workflow

- Save the notes as `docs/release_notes/YYYY-MM-DD_vX.Y.Z.md`, set `lib/version.rb` to `X.Y.Z`, and use the Git tag `vX.Y.Z` as the GitHub release title.
- Draft locally and get explicit user approval before committing the release notes, creating or pushing the tag, publishing the GitHub release, or deploying it.
