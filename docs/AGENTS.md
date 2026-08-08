# Documentation instructions

The source for the public help site lives in this directory. The standalone
Ruby builder renders Markdown through a Phlex template without booting Rails.
By default it writes the site to `public/docs/` with URLs under `/docs`.
Setting `DOCS_REDIRECT_TARGET` with an empty base path generates Cloudflare
Bulk Redirect CSV files for moving `help.loomio.com` to the canonical site.

- Keep user-manual source files under `docs/user_manual/`. Add every page that
  should be published to `docs/SUMMARY.md`; the builder does not publish
  orphaned Markdown files.
- Write internal help links from the help-site root, beginning with `/en/`, and
  omit `.html`, `index.html`, and trailing slashes, for example
  `/en/user_manual/groups/settings`. The builder adds the configured hosting
  base path and rewrites relative asset paths where necessary.
- Redirect source keys in `docs/redirects.yml` are relative to the generated
  `/en/` directory and must not start with `/en/`. Redirect targets should use
  the complete help-site path beginning with `/en/`.
- When a public page path changes, retain its old URL in `docs/redirects.yml`.
  The Cloudflare export includes both current and legacy help URLs; the `/docs`
  build contains canonical pages and its landing redirect only.
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
  `docs/user_manual/changelog/` into the static changelog index, newest first.
  Keep each entry in `docs/SUMMARY.md` as well so its individual page is
  published and linked in the navigation.
