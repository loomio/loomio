#!/usr/bin/env bash
set -euo pipefail

SITE_DIR="${1:-docs/public}"
DOMAIN="https://help.loomio.com"
SITEMAP="$SITE_DIR/sitemap.xml"
failures=0
content_pages=0
redirect_pages=0
alias_pages=0

fail() {
  echo "SEO ERROR: $*" >&2
  failures=$((failures + 1))
}

if [ ! -f "$SITEMAP" ]; then
  echo "SEO ERROR: sitemap not found: $SITEMAP" >&2
  exit 1
fi

while IFS= read -r -d '' file; do
  case "$(basename "$file")" in
    404.html|error.html|maintenance.html|print.html|toc.html) continue ;;
  esac

  relative="/${file#"$SITE_DIR"/}"
  url="$DOMAIN$relative"

  if grep -qi 'http-equiv="refresh"' "$file"; then
    redirect_pages=$((redirect_pages + 1))
    if grep -Fq "<loc>$url</loc>" "$SITEMAP"; then
      fail "redirect page is listed in sitemap: $url"
    fi

    redirect_canonical="$(sed -n 's/.*<link rel="canonical" href="\([^"]*\)">.*/\1/p' "$file" | head -n 1)"
    case "$redirect_canonical" in
      "$DOMAIN"/*)
        redirect_target="$SITE_DIR/${redirect_canonical#"$DOMAIN"/}"
        if [ ! -f "$redirect_target" ]; then
          fail "redirect canonical target has no deployed file: $url -> $redirect_canonical"
        fi
        ;;
      *) fail "redirect is missing an absolute canonical URL: $url" ;;
    esac
    continue
  fi

  description="$(sed -n 's/.*<meta name="description" content="\([^"]*\)">.*/\1/p' "$file" | head -n 1)"
  if [ -z "$description" ]; then
    fail "missing or empty meta description: $url"
  fi

  if ! grep -Eq '<title>[^<]+ - Loomio Help</title>' "$file"; then
    fail "missing descriptive title: $url"
  fi

  canonical="$(sed -n 's/.*<link rel="canonical" href="\([^"]*\)">.*/\1/p' "$file" | head -n 1)"
  if [ -z "$canonical" ]; then
    fail "missing canonical link: $url"
  elif [ "$canonical" = "$url" ]; then
    content_pages=$((content_pages + 1))
    if ! grep -Fq "<loc>$url</loc>" "$SITEMAP"; then
      fail "canonical content page is absent from sitemap: $url"
    fi
  else
    alias_pages=$((alias_pages + 1))
    if grep -Fq "<loc>$url</loc>" "$SITEMAP"; then
      fail "non-canonical alias is listed in sitemap: $url"
    fi

    case "$canonical" in
      "$DOMAIN"/*)
        canonical_file="$SITE_DIR/${canonical#"$DOMAIN"/}"
        if [ ! -f "$canonical_file" ]; then
          fail "alias canonical target has no deployed file: $url -> $canonical"
        fi
        ;;
      *) fail "canonical URL is not absolute or is outside the canonical domain: $url -> $canonical" ;;
    esac
  fi
done < <(find "$SITE_DIR/en" -name '*.html' -type f -print0)

duplicate_urls="$(sed -n 's#.*<loc>\([^<]*\)</loc>.*#\1#p' "$SITEMAP" | sort | uniq -d)"
if [ -n "$duplicate_urls" ]; then
  fail "duplicate sitemap URLs: $duplicate_urls"
fi

while IFS= read -r url; do
  [ -z "$url" ] && continue

  case "$url" in
    "$DOMAIN"/*) ;;
    *) fail "sitemap URL is outside the canonical domain: $url"; continue ;;
  esac

  file="$SITE_DIR/${url#"$DOMAIN"/}"
  if [ ! -f "$file" ]; then
    fail "sitemap URL has no deployed file: $url"
    continue
  fi

  if grep -qi 'http-equiv="refresh"' "$file"; then
    fail "sitemap URL resolves to a redirect page: $url"
  fi
done < <(sed -n 's#.*<loc>\([^<]*\)</loc>.*#\1#p' "$SITEMAP")

if [ "$failures" -gt 0 ]; then
  echo "$failures SEO validation error(s)" >&2
  exit 1
fi

echo "checked $content_pages canonical pages and excluded $redirect_pages redirect pages and $alias_pages aliases"
