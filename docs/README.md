# Help site sources

English pages live in `docs/en/`. Other languages use the same paths: `docs/fr/user_manual/users/bookmarks/index.md` is the French version of `docs/en/user_manual/users/bookmarks/index.md`. The shared `SUMMARY.md` lists the pages in navigation order, using paths relative to each language directory. Builder scripts, styles, redirects, internal plans and release notes remain directly under `docs/`.

## Fixing a translation

Open the Markdown page for your language on GitHub, select the pencil button, change the wording, and submit the change. Edit the text below the frontmatter. Keep `translation-section` comments intact; you can freely split paragraphs or improve headings within a section. You do not need to update hashes, mark your work reviewed, or write a correction note.

The next translation run records your correction automatically. Later updates receive your corrected wording and the recorded corrections as context. Notes from other pages in the same language also provide examples of preferred wording. This supplies guidance to the translator; it does not train the underlying model. Machine translations can publish after automated checks, and human review is optional.

## Updating translations

```bash
bundle exec ruby docs/translate.rb fr
bundle exec ruby docs/translate.rb fr user_manual/users/bookmarks/index.md
```

The script calls `codex exec` with `gpt-6.1-sol` by default, using the CLI’s existing login. Override it with `DOCS_TRANSLATOR_MODEL`; `DOCS_TRANSLATOR_EFFORT` defaults to `low`. Each request runs in read-only, ephemeral mode and returns JSON, which the Ruby script validates before writing Markdown.

The translator seeds stable section IDs on new English pages and updates only missing or stale sections. When adding a section to an existing page, give it a new `<!-- translation-section: unique-id -->` comment at its start. Keep existing IDs when renaming headings or changing wording. Sections may contain multiple paragraphs, lists, alerts and images.

Frontmatter records source and generated fingerprints, navigation titles and translation provenance. Customer edits are recognized from the generated fingerprints. Correction comments retain before/after wording when the generated version is available in Git; otherwise they retain the preferred wording. These comments are carried forward automatically. Exceptional terminology warnings are informational.

## Building and previewing

```bash
bundle exec ruby docs/build.rb
DOCS_LOCALES=fr,de bundle exec ruby docs/build.rb
bundle exec ruby -Itest -e 'Dir["test/docs/*_test.rb"].sort.each { |file| require_relative file }'
```

The default build includes English and languages marked `published` in `locales.yml`. `DOCS_LOCALES` selects additional languages for preview. A published language must have complete, current translations that pass structural validation. Preview builds omit pages that fail those checks. Public paths remain `/docs/en/...`, `/docs/fr/...`, and so on.

English images and downloads are shared. Put a localized replacement at the equivalent path under the language's directory to override it. Use the existing screenshot workflow for application images; moving the source directories does not require new screenshots.

See [AGENTS.md](AGENTS.md) for builder, redirect and screenshot instructions and [the localization plan](system/user_manual_localization_plan.md) for the design constraints.
