#!/usr/bin/env bash
set -euo pipefail

BOOK_DIR="docs/book"

if [ ! -d "$BOOK_DIR" ]; then
  echo "error: $BOOK_DIR not found. Run 'mdbook build docs' first." >&2
  exit 1
fi

# docs/ is the mdBook source root so the established docs/user_manual paths
# remain unchanged. mdBook copies non-Markdown source files automatically;
# remove source-only configuration, scripts, and static/theme duplicates from
# the generated book before it is validated or published.
rm -rf "$BOOK_DIR/static" "$BOOK_DIR/theme"
rm -f \
  "$BOOK_DIR/book.toml" \
  "$BOOK_DIR/check-links.sh" \
  "$BOOK_DIR/check-redirects.sh" \
  "$BOOK_DIR/check-seo.sh" \
  "$BOOK_DIR/clean-book.sh" \
  "$BOOK_DIR/generate-meta-descriptions.js" \
  "$BOOK_DIR/generate-sitemap.sh"
