# User-manual and help-site instructions

Read [writing.md](writing.md) before writing documentation. Paths in these instructions are relative to the repository root unless a Markdown link specifies otherwise.

- Read [user_manual_translations.md](user_manual_translations.md) when translating the manual or changing its translation tooling, and when preparing a feature for merge.
- Read [user_manual_screenshots.md](user_manual_screenshots.md) when generating, changing, reviewing, or publishing manual screenshots, and when preparing a feature for merge.
- Follow [release_notes.md](release_notes.md) for release notes and release preparation.
- These instruction files live under `docs/agents/`; they are repository guidance, not help-site pages. Do not add them to `docs/SUMMARY.md`.

## User manual

- Loomio publishes `docs/en/user_manual/` with its own documentation site builder in `docs/build.rb`. When developing user-visible features or behaviour changes, consider the user manual's audience and update the relevant pages so the documentation stays in sync with the application. Follow `docs/AGENTS.md` when editing documentation.
- During feature development, update the English manual only. Defer user-manual translations and documentation screenshot generation until the feature is ready for merge, unless the user explicitly requests them earlier. Validate English changes with `DOCS_LOCALES=en bundle exec ruby docs/build.rb`; complete translations, affected documentation screenshots, and the full documentation build when preparing the feature for merge.

## Changelog

- Add a new Markdown file under `docs/en/user_manual/changelog/` only for new features, changes to behaviour that users would notice, or fixes for long-standing bugs. Do not add changelog entries for minor or routine bug fixes.
- Name changelog files with the current date and a short feature slug, for example `2026-07-07_tags_improvements.md`. Write for Loomio power users: explain what changed, who can use it, permission effects, and visible workflow or interface changes without describing internal implementation details.

## API code examples

- Use cURL for API request examples. Add language-specific examples only when the user requests them or the page explains that language's integration.
- Put the URL first, followed by one option per line with shell continuation backslashes. Quote URLs containing query parameters.
- Use `-H 'Authorization: Bearer YOUR_API_KEY'` for authentication and `--json` for JSON request bodies. `--json` sets the JSON headers and selects POST automatically; omit redundant `Content-Type` headers and `-X POST`. Use `-X PATCH` or `-X DELETE` where required.
- Pretty-print JSON with two-space indentation and readable arrays. Keep the JSON body inside single quotes, with its keys indented beneath `--json`. JSON line breaks and indentation work inside that shell argument.
- Keep examples directly copyable. Prefer an inline JSON body over here-documents, separate payload files, shell loops, or extra scripting. Choose simple sample text that does not need shell escaping.
- Use clear placeholders, fictional names, and reserved example domains. Do not include real API keys, customer details, or customer names.
- Show both simple option-name arrays and detailed option objects where both are supported. Explain poll-level and option-level fields separately.
- Use a future closing date in examples that open voting, or omit it when demonstrating a draft. Explain that omitting `closing_at` disables voting and does not hide the poll from its readers.
- Check shell syntax and parse each JSON body after editing examples. Verify documented request fields against the implementation and relevant tests. Do not execute mutating examples against a production API to validate documentation.

Use this format:

```bash
curl https://www.loomio.com/api/b2/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Meeting venue",
    "poll_type": "poll",
    "options": [
      "Town hall",
      "Library"
    ]
  }'
```

## Help-site source and build

The source and builder for the public help site live under `docs/`. The standalone Ruby builder renders Markdown through a Phlex template without booting Rails. By default it writes the site to `public/docs/` with URLs under `/docs`. Setting `DOCS_REDIRECT_TARGET` with an empty base path generates Cloudflare Bulk Redirect CSV files for moving `help.loomio.com` to the canonical site.

- Keep user-manual source files under `docs/en/user_manual/`. Add every page that should be published to `docs/SUMMARY.md`; the builder does not publish orphaned Markdown files. Dated changelog files are source fragments for the consolidated changelog and are the exception to this rule.
- Write internal help links from the help-site root, beginning with `/en/`, and omit `.html`, `index.html`, and trailing slashes, for example `/en/user_manual/groups/settings`. The builder adds the configured hosting base path and rewrites relative asset paths where necessary.
- Redirect source keys in `docs/redirects.yml` are relative to the generated `/en/` directory and must not start with `/en/`. Redirect targets should use the complete help-site path beginning with `/en/`.
- When a public page path changes, retain its old URL in `docs/redirects.yml`. The Cloudflare export includes both current and legacy help URLs, and the `/docs` build includes static redirects for legacy paths.
- During feature development, update the English manual and defer translations and documentation screenshot generation until the feature is ready for merge, unless the user explicitly requests them earlier. Validate English links, images, redirects, metadata, and the sitemap after changing manual pages, navigation, assets, or redirects:

  ```bash
  DOCS_LOCALES=en bundle exec ruby docs/build.rb
  ```

- When the feature is ready for merge, complete the affected translations and documentation screenshots, then validate the full site:

  ```bash
  bundle exec ruby docs/build.rb
  ```

- Generate the two ordered Cloudflare Bulk Redirect lists with:

  ```bash
  DOCS_OUTPUT=/tmp/loomio-help-redirects \
    DOCS_BASE_PATH="" \
    DOCS_REDIRECT_TARGET=https://www.loomio.com/docs \
    bundle exec ruby docs/build.rb
  ```

  Import `cloudflare-help-exact.csv` first and `cloudflare-help-prefixes.csv` second. Enable one Bulk Redirect Rule for each list in that order so exact legacy mappings take precedence over prefixes.

- The renderer derives search descriptions from the first substantive paragraph. Add a near-top `<!-- seo-description: ... -->` override when that paragraph is not a useful page summary.
- The renderer concatenates dated files under `docs/en/user_manual/changelog/` into the static changelog index, newest first. Do not add dated entries to `docs/SUMMARY.md`; they are published only as part of the consolidated changelog page.
