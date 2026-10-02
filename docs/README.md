# Help site sources

English pages live in `docs/en/`. Other languages use the same paths: `docs/fr/user_manual/users/bookmarks/index.md` is the French version of `docs/en/user_manual/users/bookmarks/index.md`. The shared `SUMMARY.md` lists the pages in navigation order, using paths relative to each language directory. Builder scripts, styles, redirects, internal plans and release notes remain directly under `docs/`.

## Fixing a translation

Open the Markdown page for your language on GitHub, select the pencil button, change the wording, and submit the change. Edit the text below the frontmatter. Keep `translation-section` comments intact; you can freely split paragraphs or improve headings within a section. You do not need to update hashes, mark your work reviewed, or write a correction note.

The next translation run records your correction automatically. Later updates receive your corrected wording and the recorded corrections as context. Notes from other pages in the same language also provide examples of preferred wording. This supplies guidance to the translator; it does not train the underlying model. Machine translations can publish after automated checks, and human review is optional.

## Updating translations

```bash
bundle exec ruby docs/translate.rb fr
bundle exec ruby docs/translate.rb fr user_manual/users/bookmarks/index.md
bundle exec ruby docs/sync_translations.rb
```

`docs/sync_translations.rb` checks every published language for missing or stale sections, navigation titles and customer corrections. It starts the translator only for affected pages, using the same local login as an explicit translation run. Run it after committing English user_manual changes, then commit the translations it writes.

The installed local pre-push hook runs `docs/sync_translations.rb --check`, which makes no translation requests. When translations are missing, stale or structurally invalid, it stops the push; run the sync, commit its output, and push again. `SKIP_TRANSLATIONS` skips the local checks when present.

The documentation GitHub Action runs `docs/sync_translations.rb --check` and builds the complete site on pull requests and pushes to master. CI makes no model requests. Missing, stale or structurally invalid published translations fail the check; the site build also validates links, images, redirects and search. Successful builds are saved as workflow artifacts. Docker builds the site from its checkout into `public/docs/` during deployment. A documentation build failure prints a warning and removes the incomplete site without stopping the application build; documentation will be unavailable in that image. R2 stores translated screenshots and their generation manifests.

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

Application help buttons, Read more links and the sidebar manual link use the active app language and the published locale mapping in `locales.yml`. Its `app_locale` field maps `pt_BR` to `pt-br` and `nl_NL` to `nl`; other published locale names match their documentation directories. Unsupported app languages use English. Policies and the changelog stay in English, and a host-specific `LOOMIO_HELP_URL` remains the sidebar destination when supplied.

English images and downloads are shared. Only English screenshots are committed. Application screenshots with an approved capture recipe try local files under `/docs-screenshots/`, then `https://user-manual-screenshots.loomio.com/<locale>/...`, then the bundled English image. Photos, diagrams, downloads and images without a recipe remain shared English assets.

## Optional translated screenshots

Generation runs separately from Docker builds and deployment. It uses the existing Nightwatch recipes and isolated test application to capture translated interface labels, with fixed fictional example content. It never runs against the production database. The default output is the ignored `public/docs-screenshots/` directory. Vite builds directly into its own `public/vue/` directory, so a frontend rebuild cannot clear the screenshot cache.

```bash
bin/docs-screenshots all --status
bin/docs-screenshots fr users/bookmarks
bin/docs-screenshots fr users/bookmarks --refresh
bin/docs-screenshots fr users/bookmarks --publish
bin/docs-screenshots fr,de --output /path/to/docs-screenshots
```

The command generates missing files. Use local knowledge of the work to select the images or manual directories that need updating, then use `--refresh` to regenerate every selected image, including existing files. There are no automatic stale-image rules. A single `.generation.json` records each language/path's generation time. PNG filenames stay stable, and every update replaces the previous file atomically. Failed captures leave the existing cache intact. `--status` reports missing and present images without starting a browser or creating files. `all` selects every published language.

Generate the affected screenshots locally before committing, alongside the translation workflow. Screenshot generation does not run on GitHub. Review the local captures, then rerun the same selection with `--publish` to upload it to R2. Existing files are reused unless you also pass `--refresh`; missing files are generated before publishing. Uploads use the Cloudflare `cf` CLI in development mode, which loads `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN` from the project's ignored `.env.development.local`. Keep the token in that local file, outside Git. Each language's manifest is uploaded after its selected images succeed. A failed generation leaves completed captures locally without publishing; a failed image upload leaves the previous hosted manifest in place. Nothing is deleted, and no historical copies are created.

Each language runs the existing scenario and navigation steps from the beginning. Interface labels are translated, while fictional discussion and poll content remains fixed. Live language switching and translation of example content are not part of this workflow.

Publishing writes only translated PNGs and generation manifests to the `user-manual-screenshots` bucket. The bucket's public hostname is `user-manual-screenshots.loomio.com`. GitHub does not generate or publish screenshots, and this workflow does not use repository R2 secrets.

The Docker image links `/public/vue` to the existing persistent `/public/client3` directory and `/public/docs-screenshots` to its `docs-screenshots` subdirectory. Container startup copies the current build from `/loomio/vue-build` into that volume. Existing Kamal and Compose mounts continue to work, and older clients retain their `/client3/...` URLs with the existing 90-day asset retention policy.

Every host automatically tries its own `/docs-screenshots/<locale>/...` files before requesting R2's copy. Missing or unreachable copies fall back to English. Building locally supplies the first choice without configuration. With JavaScript disabled, the built English screenshot remains available. The client asset sync excludes `docs-screenshots/` from its 90-day pruning policy.

See [AGENTS.md](AGENTS.md) for builder, redirect and screenshot instructions and [the localization plan](system/user_manual_localization_plan.md) for the design constraints.
