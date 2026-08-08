#!/bin/bash
# Verify every redirect target in docs/book.toml points at a file that
# actually exists in the built book. Run after `mdbook build docs`.
set -euo pipefail

BOOK_DIR="docs/book"
TOML="docs/book.toml"

if [ ! -d "$BOOK_DIR" ]; then
  echo "error: $BOOK_DIR not found. Run 'mdbook build docs' first." >&2
  exit 1
fi

failures=0
count=0

# Pull out each "from" = "to" line inside [output.html.redirect]
while IFS= read -r line; do
  from=$(echo "$line" | sed -E 's/^"([^"]+)".*/\1/')
  to=$(echo "$line" | sed -E 's/^[^=]+= *"([^"]+)".*/\1/')

  count=$((count + 1))

  # The gh-pages workflow does `mv docs/book/* docs/public/en/`, so every file
  # mdbook writes under book_dir ends up nested one level deeper under
  # "/en" on the live site. A "from" key that itself starts with "/en/"
  # would therefore double-nest (mdbook writes the stub to
  # book_dir/en/user_manual/... which deploys to /en/en/user_manual/...)
  # and never match the real broken URL. "from" keys must NOT start with
  # "/en/".
  if [[ "$from" == /en/* ]]; then
    echo "BROKEN: \"$from\" -> \"$to\" (from-path starts with /en/, will double-nest to /en$from on deploy)"
    failures=$((failures + 1))
    continue
  fi

  # Redirect targets are site-absolute paths (e.g. "/en/user_manual/foo.html"
  # or "/guides/foo.html"); the book is deployed as docs/book/* -> docs/public/en/*,
  # so strip a leading "/en" to get the book-relative path.
  target="${to#/}"
  target="${target#en/}"
  resolved="$BOOK_DIR/$target"

  if [ ! -f "$resolved" ]; then
    echo "BROKEN: \"$from\" -> \"$to\" (no file at $resolved)"
    failures=$((failures + 1))
    continue
  fi
done < <(grep -E '^"[^"]+"\s*=\s*"[^"]+"' "$TOML")

echo ""
echo "checked $count redirects, $failures broken"
[ "$failures" -eq 0 ]
