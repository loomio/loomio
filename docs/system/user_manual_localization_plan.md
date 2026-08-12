# User manual localization plan

## Initial languages

Start with French (`fr`), Spanish (`es`), and German (`de`). In a sample of the
50,000 users with the most recent `last_seen_at` values in the development
database, these were the three most common non-English locales:

| Locale | Users | Share of sample | Share of non-English users |
| --- | ---: | ---: | ---: |
| French (`fr`) | 3,947 | 7.89% | 33.68% |
| Spanish (`es`) | 3,717 | 7.43% | 31.72% |
| German (`de`) | 930 | 1.86% | 7.94% |

The sample covered `last_seen_at` values from 19 July 2022 through 7 August
2026. Recheck production usage before adding later languages.

## Translation model

Keep the English Markdown under `docs/user_manual/` as the canonical source.
Do not send raw Markdown to the translation service. Parse each page and
produce protected HTML or another structured representation with stable block
IDs. Translate one complete page at a time so headings and paragraphs provide
context, then store the translated output by block.

Each translated block should record:

- its stable block ID and English source hash;
- the translated HTML;
- the translation provider and model;
- the translation date;
- whether it is machine translated, reviewed, or stale;
- an optional reviewer and translation note.

When English changes, mark only affected blocks stale. A translation request
may include the complete page for context, but reviewed unchanged blocks must
not be overwritten.

Use a glossary for Loomio terminology, poll and proposal language, product
names, and text that must remain unchanged. Seed it from the existing locale
files and `config/locales/translation_corrections.md`. Preserve the established
register rules, including informal Spanish `tú` and the locale-specific choices
already documented in `AGENTS.md`.

## Localized screenshots

Treat screenshots as locale-specific generated artifacts. Extend
`bin/e2e-screenshots` with a locale argument and run the existing deterministic
Oatmilk Cooperative scenarios with:

- a user whose selected locale matches the requested screenshot locale;
- translated application UI;
- deterministic translated example discussions, comments, polls, and outcomes;
- locale-specific output paths while retaining the same logical screenshot
  name as English.

Record enough generation metadata to identify stale screenshots when their
testcase, scenario, relevant UI translations, locale, or application revision
changes. Check localized captures for text overflow, clipped controls, complete
thread-item gutters and avatars, and right-to-left layout when later languages
require it.

## Build and validation

Generate locale routes such as `/docs/fr/`, `/docs/es/`, and `/docs/de/`, with
localized navigation, metadata, internal links, and screenshot lookup. Validate
that every published locale has the same page and block structure as English.
Reject builds with:

- missing or extra block IDs;
- altered URLs, commands, filenames, code, or interpolation variables;
- broken internal links or missing localized assets;
- invalid generated HTML;
- stale reviewed translations where the release policy requires current text;
- known terminology or register regressions.

## Rollout

1. Add locale-aware builder routes, translation storage, and asset lookup.
2. Pilot one substantial page in French, Spanish, and German.
3. Machine translate parsed page HTML with stable block IDs and glossaries.
4. Have fluent reviewers correct the pilot and record terminology decisions.
5. Generate and review the corresponding localized screenshots.
6. Expand one manual section at a time, preserving reviewed translations.
7. Add further languages based on a refreshed active-user locale sample and
   the available review capacity.

Human review remains the publication gate for translated pages and localized
screenshots.
