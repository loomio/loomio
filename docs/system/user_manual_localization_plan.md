# User manual localization plan

## Goals

Publish usable translated documentation with automated checks and occasional customer improvements. A contributor should be able to open a page on GitHub, select Edit, fix the Markdown and submit it without maintaining translation metadata. Human review is optional. Corrections should provide context for future automated translations without creating a separate proposal or review queue.

## Source layout

English remains canonical under `docs/en/`. Translations mirror its paths under `docs/<locale>/`, for example `docs/en/user_manual/users/bookmarks/index.md` and `docs/fr/user_manual/users/bookmarks/index.md`. Translate the user manual and guides; keep policy pages and the changelog in English. Keep one shared `docs/SUMMARY.md` with page paths relative to each language directory. Navigation titles come from the summary for English and page frontmatter for other languages. Shared scripts, styles, redirects, internal documentation and release notes remain under `docs/`.

Keep public routes unchanged: `/docs/en/...`, `/docs/fr/...`, and corresponding language paths. Translated headings retain English anchor IDs. Links between translated pages use the current language; links to English-only material remain in English.

## Translation units and storage

Translated pages are ordinary Markdown. Stable `translation-section` comments identify sections in English and translated files. Seed readable IDs from headings once; never regenerate an existing ID when its heading changes. A section can contain several paragraphs, lists, tables, code, alerts and images. Paragraph splitting does not change its identity.

Small page frontmatter holds the translated navigation title, source fingerprints by section ID, generated text fingerprints by section ID, available Git source provenance, the last translation provider/date and exceptional terminology warnings. Keep metadata outside the prose. Source fingerprints detect changed English; generated fingerprints recognize human corrections without asking contributors to set review flags. Repeated English text and routine per-paragraph provider/date fields are unnecessary.

Send parsed section HTML to the translation service with the full page for context, the app glossary and any previous corrected wording. Return Markdown and validate its structure using the same parser settings as the site renderer. Preserve URLs, image paths, code, heading levels, lists, tables, literal HTML and alert markers. Preserve the established language register and use `config/locales/translation_corrections.md` for known terminology errors. Inflected interface labels may produce an informational terminology note rather than blocking a valid translation.

## Customer corrections

An unchanged English section keeps its current translated text. The next translation run detects customer edits and records the difference from the matching generated version in a `translation-correction` comment, even if no translation request is needed. Git history supplies the baseline; if a generated version has not been committed, retain the preferred wording instead. Customers do not need to write these comments themselves.

When English changes a corrected section, translate it automatically using the customer's version and its correction notes as context. Keep those notes with the section and supply them to subsequent requests. This provides translation context and does not train the underlying model. There is no mandatory human review, special approval state or proposal queue. Failed structural validation retains the existing translated section and reports the failure for rerunning the translation job.

Git source provenance identifies an available committed baseline. English can be translated before it is committed; a prior Git section is used as the previous English only if its fingerprint matches the recorded source fingerprint.

## Screenshots and assets

Commit only English screenshots. Generate translated application screenshots separately with the existing deterministic Oatmilk Cooperative recipes, using translated interface labels and fixed fictional example content. `bin/docs-screenshots` fills missing images; `--refresh` also replaces outdated images. A single manifest tracks generation time and capture-input fingerprints while PNGs keep stable paths and overwrite their previous versions. Generation and publishing remain optional steps outside Docker builds and deployment.

Store generated images under `public/docs-screenshots/<locale>/...`, backed by loomio.com's existing persistent client asset volume. Exclude that directory from frontend asset pruning. Runtime image lookup tries local translated files, then the equivalent `www.loomio.com` URL, then bundled English. Private hosts need neither generation nor new storage; populating their existing volume automatically takes priority. Keep English images usable without JavaScript. Photos, diagrams, downloads and assets without a capture recipe remain shared. Check clipping, text overflow and right-to-left layout when adding or changing capture recipes.

## Build and publication

Build English and published languages by default; use `DOCS_LOCALES` to preview other languages. Machine translations may publish after automated validation. A published language requires every manual and guide page to be complete, current and structurally valid; preview builds omit incomplete or stale pages. Optional terminology notes do not prevent publication.

Validate links, images, metadata, redirects, heading anchors, language attributes and the sitemap. Apply structural validation to hand-edited translations as well as generated text. Regression coverage must include heading renames, paragraph splitting, inserted/deleted sections, customer corrections, repeated translation runs, failed translations and localized asset lookup.

## Migration

Convert the existing block YAML mechanically, retaining all translated text without model requests. Add stable section markers to English, assemble the corresponding translated sections, and carry forward exceptional notes and available provenance. Compare every rendered page before and after the conversion, including text, code, links, images, anchors, navigation and metadata. Update screenshot output paths and API specification consumers with the English directory move.

The initial implementation translated 85 pages into 13 languages. Keep those languages available for preview; enable publication separately through `docs/locales.yml` when their automated checks and operator rollout are ready.
