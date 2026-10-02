# Documentation instructions

The source for the public help site lives in this directory. The standalone
Ruby builder renders Markdown through a Phlex template without booting Rails.
By default it writes the site to `public/docs/` with URLs under `/docs`.
Setting `DOCS_REDIRECT_TARGET` with an empty base path generates Cloudflare
Bulk Redirect CSV files for moving `help.loomio.com` to the canonical site.

- Keep user-manual source files under `docs/en/user_manual/`. Add every page that
  should be published to `docs/SUMMARY.md`; the builder does not publish
  orphaned Markdown files. Dated changelog files are source fragments for the
  consolidated changelog and are the exception to this rule.
- Write internal help links from the help-site root, beginning with `/en/`, and
  omit `.html`, `index.html`, and trailing slashes, for example
  `/en/user_manual/groups/settings`. The builder adds the configured hosting
  base path and rewrites relative asset paths where necessary.
- Redirect source keys in `docs/redirects.yml` are relative to the generated
  `/en/` directory and must not start with `/en/`. Redirect targets should use
  the complete help-site path beginning with `/en/`.
- When a public page path changes, retain its old URL in `docs/redirects.yml`. The Cloudflare export includes both current and legacy help URLs, and the `/docs` build includes static redirects for legacy paths.
- Build and validate links, images, redirects, metadata, and the sitemap after
  changing manual pages, navigation, assets, or redirects:

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

  Import `cloudflare-help-exact.csv` first and
  `cloudflare-help-prefixes.csv` second. Enable one Bulk Redirect Rule for each
  list in that order so exact legacy mappings take precedence over prefixes.

- The renderer derives search descriptions from the first substantive
  paragraph. Add a near-top
  `<!-- seo-description: ... -->` override when that paragraph is not a useful
  page summary.
- The renderer concatenates dated files under
  `docs/en/user_manual/changelog/` into the static changelog index, newest first.
  Do not add dated entries to `docs/SUMMARY.md`; they are published only as
  part of the consolidated changelog page.

## Translated manual

English source pages live under `docs/en/`. Translated pages mirror their paths under `docs/<locale>/`, for example `docs/en/user_manual/users/bookmarks/index.md` and `docs/fr/user_manual/users/bookmarks/index.md`. The user manual and guides are translated; policy pages and the changelog stay in English. Shared navigation order lives in `docs/SUMMARY.md`, whose page paths are relative to each language directory.

- Edit translated prose directly as Markdown. Customers do not need to change frontmatter, mark sections reviewed, or maintain a correction log. Keep section comments intact when editing words, splitting paragraphs, or renaming headings.
- `<!-- translation-section: stable-id -->` marks a translation unit. IDs are unique within a page and remain unchanged when the text changes. Seed a new English page's IDs with `docs/translate.rb`; when adding a section to an existing page, give it a new marker and copy the marker to its translation only when supplying the translated text.
- Frontmatter holds the translated navigation `title`, English section hashes in `sections`, generated text hashes in `generated`, Git source provenance where available, the last translation provider/date, and exceptional `needs_review` notes. The generated hashes detect customer edits automatically. They are fingerprints, not section identities.
- Update a language with `bundle exec ruby docs/translate.rb <locale> [<page.md>...]`. Omit pages to process every manual and guide page in the shared summary. The script learns customer corrections even when English has not changed, without making a translation request. It translates only missing or stale sections and removes sections deleted from English.
- Run `bundle exec ruby docs/sync_translations.rb` to update every published language after committing English user_manual changes, and commit the translations it writes before pushing. The local pre-push hook and the documentation GitHub Action only check freshness with `--check`; neither invokes the translator. When the hook stops a push, run the sync, commit its output, and push again.
- When English changes a corrected section, update it automatically using the customer's version and previous correction notes as context. Record the customer's before/after wording in a `translation-correction` comment when Git contains the matching generated baseline. For an uncommitted generated baseline, record the preferred text instead. Keep notes with their section and give them to later translation requests. These notes do not create a review queue.
- Translation requests receive named sections as Markdown with full-page context. Validate returned Markdown against the English using the site's Markdown parser: heading levels, lists, tables, link/image targets, code, literal HTML, and alert markers. Run the same structural checks at build time, including on customer edits. Terminology warnings are recorded for information and do not block otherwise valid translations.
- A language builds when it is published in `docs/locales.yml` or requested through `DOCS_LOCALES`, for example `DOCS_LOCALES=fr,de bundle exec ruby docs/build.rb`. Machine translations may be published after automated validation; human review is optional. Published languages require every translated page to be complete, current and structurally valid. Preview builds omit incomplete or stale pages, using English navigation links for those pages.
- Translated headings retain English anchor IDs, and links between translated pages use the current language. Reuse English screenshots and downloads by default; an asset at the equivalent `docs/<locale>/...` path overrides the English asset without copying all images into every locale.
- Commit only English screenshots. Generate translated application images manually with `bin/docs-screenshots <locale,...|all> [image-or-directory...]`; `all` selects published languages, `--status` reports missing and present files, and `--refresh` regenerates every selected image. Choose the affected images or manual directories using the context of the work, before committing, as with translations. Do not add automatic stale-image rules or generation triggers on push. Generated PNGs and `.generation.json` live under the ignored `public/docs-screenshots/` cache or an explicit `--output` directory. Keep filenames stable and update the manifest only after successful captures. The manually dispatched screenshot GitHub Action accepts language and path selections, restores each language's R2 cache, and publishes completed images and its manifest from trusted master runs. Each language keeps its existing scenario setup and navigation; do not add live language switching or translate fictional content as part of this workflow. Runtime lookup uses local images, then `user-manual-screenshots.loomio.com`, then bundled English. Generation and publishing happen outside deployment; preserve local screenshot caches during client asset pruning.
- The documentation GitHub Action validates the complete site and saves successful builds as workflow artifacts. Docker builds the static site into `public/docs/` from its own checkout during deployment. Documentation failures must fail CI, but the Docker build warns, removes incomplete output and continues without documentation. Publish only translated screenshots and their generation manifests to R2. Keep publishing credentials out of pull-request steps.
- `docs/<locale>/_site.yml` contains site interface strings. Each language's style (register and conventions) and terminology come from its app locale's entry in `config/locales/glossary.yml`, shared with the app strings.
- `bundle exec ruby docs/sync_translations.rb --retranslate` translates every section of every page again, for example after the glossary changes. Customer corrections still travel as context. `DOCS_TRANSLATION_JOBS` sets how many pages are translated at once (default 8).

## User-manual screenshot workflow

Application screenshots in `docs/en/user_manual/` are generated by the dedicated Nightwatch specs under `vue/tests/e2e/screenshots/`. Keep each generated image in the same directory as the Markdown page that uses it, and reuse the existing filename when replacing a manual screenshot. Photos, diagrams, email-client screenshots, and third-party integration interfaces are not automatically in scope merely because they are images in the manual.

The screenshot runner captures PNGs at 2× device scale. The documentation builder automatically emits local PNGs with a `2x` density descriptor so they display at no more than half their pixel dimensions with automatic height; do not add per-image display dimensions for this purpose.

The screenshot helper compresses every capture as a palette PNG with `bin/compress-screenshot`, after cropping and spotlighting. Compression is deterministic and skips images that are already palette PNGs, so rerunning it never degrades an image. To compress a manually captured or replaced image, run `bundle exec ruby bin/compress-screenshot <path>`.

Do not change production UI behavior merely to make a screenshot look right.
First check capture timing, viewport changes, overlay positioning, selectors,
and crop geometry. Set the final viewport before opening a Vuetify menu or
dialog; resizing after an overlay opens can make it appear detached from its
activator even when the application behaves correctly.

Use the Oatmilk Cooperative scenarios in
`Dev::Scenarios::OatmilkCooperative` as the shared setting. Extend that story
rather than creating unrelated groups and people for each page. Keep names,
roles, group purpose, cover image, discussions, comments, polls, and dates
deterministic. Use fictional people and reserved example domains; never use
production or customer data.

Give recurring fictional participants ordinary, consistent profile photos and
reuse the Oatmilk Cooperative logo and product-image fixtures under
`vue/tests/e2e/fixtures/avatars/`. Example discussion contexts and poll details
should usually contain about three short paragraphs. Use no more than three
common rich-text features per record, varying the features deterministically
between records (for example a link, bold or highlighted text, an emoji, a
list, a quote, or a small table). Do not use embedded video merely to decorate
example content. Use the branded oatmilk bottle or warehouse-box fixtures when
an inline-image example is needed.

Work through screenshot replacements one image at a time:

1. Read the complete help page containing the image and inspect the existing
   image before overwriting it. Use the page's heading, instructions, image
   position, and adjacent text to determine the job the image must do. Identify
   the exact interface state, signed-in role, permissions, crop, viewport, open
   menus or dialogs, entered form values, and instructional focus.
2. Look for an existing spotlight treatment. A spotlight usually appears as a
   bright control or menu over a dimmed page. Reproduce that emphasis in the
   generated image; do not silently replace it with an unhighlighted
   screenshot. Keep the spotlight borderless, with enough padding and corner
   radius to separate the target naturally from the dimmed page.
3. Add or extend a deterministic dev scenario, then navigate and interact with
   the interface through Nightwatch. Prefer normal user actions over directly
   mutating frontend state.
4. Capture to the image's existing path relative to `docs/en/user_manual/` with
   `manualScreenshot.capture`, `manualScreenshot.captureElement`, or
   `manualScreenshot.captureRegion`. Use a
   stable selector and wait for the content that proves the documented state is
   ready before capturing. Run documentation screenshots at 2× device scale so
   they remain sharp at high-density display resolutions; `bin/e2e-screenshots`
   configures this without changing the ordinary behavioural E2E suite.
5. Generate only the candidate being reviewed where practical:

   ```bash
   bin/e2e-screenshots <spec>.js --testcase <testcase>
   ```

6. Visually compare the generated image with the previous image and the manual
   text. Check that it communicates the same instruction, contains no clipped
   overlays or transient UI, uses the intended crop, and remains legible at the
   rendered documentation width. Keep screenshot corner clipping in the shared
   documentation CSS rather than baking it into individual PNGs, so rounded app
   surfaces do not expose captured page-background pixels at their corners.

Use these framing defaults unless the page needs a deliberate exception:

- Be generous with context. Prefer a larger area with the subject spotlighted
  over a tight crop around the subject, so the reader can see where it sits on
  the page. A discussion or proposal example usually needs the full central
  `.strand-card`, but not the application drawer, top bar, or thread drawer.
- Do not include the application toolbar or title bar unless the screenshot also
  includes an application drawer that needs it for orientation.
- When the subject is a control inside a form or modal, show the whole form or
  modal and spotlight the control. If the form is too long for that, show about
  one screen of the form around the control, with the control spotlighted. Do
  not crop so tightly that the reader cannot identify where the control belongs.
- Give compact editor, comment, task, and menu captures about 32 pixels of
  external padding. Adjust individual images when an overlay or unusually shaped
  target needs more or less space.
- For comments, replies, reactions, unread items, and move-item states, prefer a
  full strand-card capture with the relevant item or composer spotlighted.
- When documenting a trigger and its menu, show both the activator and the open
  menu. Crop after the final meaningful action or control instead of retaining a
  large blank tail.
- Generate screenshots in light mode unless the documentation is specifically
  teaching theme selection or dark mode.
- Hide `.flash-root` by default so a previous operation's snackbar does not leak
  into an unrelated image. Set `showFlash: true` only when the flash message is
  the subject of the screenshot.

Conceptual diagrams are not application screenshots. Do not add them to the
Nightwatch screenshot suite; update their source image intentionally. Likewise,
leave images that require representative long-running real-group data out of
automated regeneration and document that they require a manual capture. The
participation-report graph is one such image; preserve its current PNG until a
suitable real-group replacement is reviewed.
7. Run `bundle exec ruby docs/build.rb` before sharing the review URL. The
   localhost documentation serves the built copy under `public/docs`, so this
   step is required for the reviewer to see the current source image.
8. Present the candidate for human review and stop. Continue to the next image
   only after the reviewer signs it off or after applying their feedback and
   presenting a revised candidate. Always give the reviewer the rendered page
   URL on the local Rails server, beginning with
   `http://localhost:3000/docs/en/`; do not use a filesystem link as the review
   link.

For a post-processed spotlight, pass the target selector in the capture
options. The screenshot helper measures the element before capture and
`bin/spotlight-screenshot` dims the PNG outside that rectangle afterward:

```js
screenshot.captureElement('groups/settings/group_settings', '.v-main', {
  spotlight: {
    selector: '.v-overlay .v-list',
    padding: 16,
    radius: 16,
    opacity: 0.4,
    outlineWidth: 0
  }
});
```

The short form `spotlight: '.selector'` uses the defaults. Target the specific
button or menu item the old image emphasizes, rather than using fixed pixel
coordinates. When spotlighting a Vuetify overlay, choose a capture root large
enough to contain the teleported menu or dialog so it is not clipped.
For adjacent controls that form one instructional target, pass a `selectors`
array; the helper spotlights their combined bounding rectangle.
Use `captureRegion` with a selectors array when a compact screenshot must
include elements rendered in separate DOM branches, such as an autocomplete
field and its teleported Vuetify suggestion menu.

After an approved screenshot changes, run the focused screenshot testcase
again if its scenario or capture changed, then rebuild and validate the
documentation:

```bash
bundle exec ruby docs/build.rb
```
