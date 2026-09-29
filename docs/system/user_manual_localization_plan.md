# User manual localization plan

Translate the user manual into other languages, including its screenshots. A translated page with English screenshots is not an acceptable result. Screenshots show the controls the reader must find, so they must show the reader's language.

## Initial languages

Start with French (`fr`), Spanish (`es`), and German (`de`). In a sample of the 50,000 users with the most recent `last_seen_at` values in the development database, these were the three most common non-English locales:

| Locale | Users | Share of sample | Share of non-English users |
| --- | ---: | ---: | ---: |
| French (`fr`) | 3,947 | 7.89% | 33.68% |
| Spanish (`es`) | 3,717 | 7.43% | 31.72% |
| German (`de`) | 930 | 1.86% | 7.94% |

The sample covered `last_seen_at` values from 19 July 2022 through 7 August 2026. Recheck production usage before adding later languages.

## Scale

As of September 2026, the manual has about 68 pages and 45,000–50,000 words, excluding the changelog. The manual and guides contain 445 screenshots, about 120 MB before compression. Each additional language adds about the same number and size of screenshots.

The manual changes often. `docs/user_manual/` had 180 commits between July and September 2026. The design must assume English changes weekly, and translations must follow without a manual retranslation project.

## Scope

Translate the user manual and guides. Keep the changelog, release notes, and policy pages in English.

## Translation model

Keep the English Markdown under `docs/user_manual/` as the canonical source. Do not send raw Markdown to the translation service. Parse each page and produce protected HTML or another structured representation with stable block IDs. Translate one complete page at a time so headings and paragraphs provide context, then store the translated output by block.

Each translated block should record:

- its stable block ID and English source hash;
- the translated HTML;
- the translation provider and model;
- the translation date;
- whether it is machine translated, reviewed, or stale;
- an optional reviewer and translation note.

When English changes, mark only affected blocks stale. A translation request may include the complete page for context, but reviewed unchanged blocks must not be overwritten.

Retranslate stale blocks as part of the same change that edits the English, so translations never lag behind. Do not build workarounds for outdated text, such as notices or English fallbacks.

## Terminology

The manual names interface controls in bold, such as **Invite** or **Members can create templates**. In a translated page, these must match the application's translation exactly, or readers cannot find the control. Build the glossary automatically from `config/locales/client.<locale>.yml` so these labels come from the same source as the interface.

Add Loomio terminology, poll and proposal language, product names, and text that must remain unchanged. Seed corrections from `config/locales/translation_corrections.md`. Preserve the established register rules, including informal Spanish `tú` and the locale-specific choices already documented in `AGENTS.md`.

## Localized screenshots

### Generation

Treat screenshots as locale-specific generated artifacts. Extend `bin/e2e-screenshots` with a locale argument and run the existing deterministic Oatmilk Cooperative scenarios with:

- a user whose selected locale matches the requested screenshot locale;
- translated application UI;
- translated example discussions, comments, polls, outcomes, and tags;
- the same logical screenshot name and capture options as English.

The example content lives in Ruby scenario helpers today, so it is English in every locale. Move the scenario text into a translatable file and translate it with the same pipeline and glossary as the manual. Keep people's names and the cooperative's name unchanged.

Generate all locales in CI, in parallel. At about 24 times the English run, full generation is not a practical local step.

### Review

Human review applies to English screenshots only, through the existing review workflow in `docs/AGENTS.md`. When an English screenshot is approved, its localized versions are accepted if they pass automated checks. Reviewing every localized screenshot individually is too expensive to be the publication gate.

The automated checks replace the problems a reviewer would catch:

- **Missing translations**: capture with a mode that marks strings falling back to English or rendering raw keys. Fail the screenshot if any appear.
- **Layout**: flag clipped or overflowing text, truncated buttons, and incomplete thread-item gutters and avatars. German and Finnish text is often 30–40% longer than English.
- **Size changes**: flag images whose dimensions differ substantially from the English version. This usually means wrapped layout or a missing element.
- **Contact sheet**: produce a thumbnail grid for each locale so someone can skim every image quickly when they choose to.
- **Right-to-left**: check spotlights and crops in mirrored layouts before adding Hebrew.

### Staleness

A localized screenshot is stale when any of these change:

- the approved English screenshot;
- its testcase or scenario;
- the locale's UI strings, tracked by a hash of `client.<locale>.yml`;
- the locale's translated scenario content.
- the application revision used to generate it.

### Compression

Compress every manual screenshot, English and localized, with lossy PNG quantization such as `pngquant`. Screenshots are flat interface colours, so quantization usually reduces them by 60–70% without a visible difference. This shrinks the English images in git and the storage and transfer for every locale.

Run compression inside `bin/e2e-screenshots` after the spotlight step, so every capture is compressed the same way. Compression must be deterministic: the same capture must produce the same bytes, or content-addressed keys change on every run. Pin the tool version and its settings.

### Storage and hosting

Localized screenshots must not be committed to git. Every regeneration would add a full set of images per language to repository history. English screenshots stay in git beside their pages, because they are reviewed there.

Host localized screenshots in a public Cloudflare R2 bucket. R2 has no egress charges, and Loomio already uses Cloudflare for help-site redirects.

- Serve the bucket from a Loomio-controlled domain, such as `screenshots.loomio.com`, not the default R2 URL. Links then survive a later change of provider.
- CI uploads each localized screenshot under a content-addressed key, such as `manual/<locale>/<logical path>/<sha256>.png`.
- Never delete or overwrite objects. An old build keeps working because the images it references still exist.
- Serve objects with long-lived immutable cache headers, because a key's content never changes.
- Commit a small manifest to the repository. It maps each locale and logical screenshot name to its current hash and generation metadata.
- The docs builder reads the manifest and writes absolute R2 URLs for localized images. Pages, navigation, and search stay local.
- Only CI holds write credentials, scoped to this bucket. Public access is read-only, with no listing.

## Build and validation

Generate locale routes such as `/docs/fr/`, `/docs/es/`, and `/docs/de/`, with localized navigation, metadata, internal links, and screenshot lookup. The builder currently hardcodes English in its site prefix, output paths, and `lang` attribute. Existing `/en/` URLs stay as they are. Pagefind builds a separate search index for each `lang` value.

Validate that every published locale has the same page and block structure as English. Reject builds with:

- missing or extra block IDs;
- altered URLs, commands, filenames, code, or interpolation variables;
- broken internal links or missing localized assets;
- localized screenshots missing from the manifest, or manifest entries whose bucket objects do not exist;
- invalid generated HTML;
- stale blocks;
- known terminology or register regressions.

## Rollout

1. Add deterministic compression to `bin/e2e-screenshots` and recompress the English screenshots.
2. Set up the R2 bucket and domain.
3. Add locale-aware builder routes, translation storage, and asset lookup.
4. Move scenario text into a translatable file.
5. Pilot one substantial page in French, Spanish, and German, with its screenshots.
6. Machine translate parsed page HTML with stable block IDs and glossaries.
7. Have fluent reviewers correct the pilot text and record terminology decisions.
8. Check the pilot's localized screenshots against the automated checks. Review them by hand once to confirm the checks are sufficient.
9. Expand one manual section at a time, preserving reviewed translations.
10. Add further languages based on a refreshed active-user locale sample and the available review capacity.

Human review remains the publication gate for translated text and English screenshots. Localized screenshots are published when their English screenshot is approved and they pass the automated checks.
