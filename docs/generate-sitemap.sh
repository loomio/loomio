#!/bin/bash
# Generate sitemap.xml from built mdBook HTML files
DOMAIN="https://help.loomio.com"
SITE_DIR="${1:-docs/public}"
OUTPUT="$SITE_DIR/sitemap.xml"

echo '<?xml version="1.0" encoding="UTF-8"?>' > "$OUTPUT"
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> "$OUTPUT"

find "$SITE_DIR/en" -name "*.html" \
  -not -name "404.html" \
  -not -name "print.html" \
  -not -name "toc.html" \
  -not -name "error.html" \
  -not -name "maintenance.html" \
  | sort | while read -r file; do
  # mdBook redirect stubs are HTTP 200 pages containing a meta refresh. They
  # must not appear in the sitemap: only canonical content URLs belong there.
  if grep -qi 'http-equiv="refresh"' "$file"; then
    continue
  fi

  path="/${file#"$SITE_DIR"/}"
  url="${DOMAIN}${path}"

  # mdBook also copies the first chapter to /en/index.html. Exclude that and
  # any future alias whose canonical points elsewhere.
  if ! grep -Fq "<link rel=\"canonical\" href=\"${url}\">" "$file"; then
    continue
  fi

  echo "  <url><loc>${url}</loc></url>" >> "$OUTPUT"
done

echo '</urlset>' >> "$OUTPUT"
