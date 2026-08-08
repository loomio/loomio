#!/bin/bash
# Verify every internal <a href> and <img src> in the built book resolves to
# a real file. Run after `mdbook build docs`.
set -euo pipefail

BOOK_DIR="docs/book"
STATIC_DIR="docs/static"

if [ ! -d "$BOOK_DIR" ]; then
  echo "error: $BOOK_DIR not found. Run 'mdbook build docs' first." >&2
  exit 1
fi

python3 - "$BOOK_DIR" "$STATIC_DIR" <<'PYEOF'
import sys, os, re
from html.parser import HTMLParser
from urllib.parse import urlsplit

book_dir = sys.argv[1]
static_dir = sys.argv[2]

class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []  # (attr, value)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "a" and attrs.get("href"):
            self.links.append(("href", attrs["href"]))
        elif tag == "img" and attrs.get("src"):
            self.links.append(("src", attrs["src"]))

def is_external(url):
    if url.startswith("https://help.loomio.com/") or url.startswith("http://help.loomio.com/"):
        return False
    return (
        url.startswith("http://") or url.startswith("https://")
        or url.startswith("mailto:") or url.startswith("tel:")
        or url.startswith("//")
    )

failures = 0
checked = 0

for root, dirs, files in os.walk(book_dir):
    for fname in files:
        if not fname.endswith(".html"):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath, encoding="utf-8", errors="replace") as f:
            content = f.read()

        parser = LinkParser()
        parser.feed(content)

        for attr, raw_url in parser.links:
            url = raw_url.strip()
            if not url or url.startswith("#") or is_external(url):
                continue

            split = urlsplit(url)
            path_part = split.path
            if not path_part:
                # pure fragment or query, already excluded above but be safe
                continue

            checked += 1

            # GitHub Pages resolves extensionless/directory paths to
            # "<path>/index.html" (redirecting "/foo" -> "/foo/" first), so
            # accept that form too before calling anything broken.
            def exists(base, rel):
                target = os.path.join(base, rel)
                if os.path.isfile(target):
                    return True, target
                index_target = os.path.join(target, "index.html")
                return os.path.isfile(index_target), index_target

            if path_part.startswith("/"):
                # Absolute paths are site-root-relative. The deploy step
                # (see gh-pages.yml) does:
                #   cp -R docs/static/* docs/public/ (static/foo -> /foo)
                #   mv docs/book/* docs/public/en/   (book content -> /en/foo)
                # so a path starting with "/en/" resolves against book_dir
                # (or static/en/*, which lands in the same public/en/ tree),
                # while anything WITHOUT the "/en/" prefix only exists if
                # static/ has a matching top-level file/dir - it is never
                # served by the book, even though the same relative path
                # may coincidentally exist inside book_dir on disk.
                rel = path_part.lstrip("/")
                if rel == "en" or rel.startswith("en/"):
                    rel = rel[len("en"):].lstrip("/")
                    resolved, target = exists(book_dir, rel)
                    if not resolved:
                        resolved, target = exists(static_dir, path_part.lstrip("/"))
                else:
                    resolved, target = exists(static_dir, rel)
                    if not resolved:
                        target = f"{static_dir}/{rel} (note: path is missing a leading /en/ segment)"
            else:
                target = os.path.normpath(os.path.join(root, path_part))
                if os.path.isfile(target):
                    resolved = True
                else:
                    target = os.path.join(target, "index.html")
                    resolved = os.path.isfile(target)

            if not resolved:
                rel_source = os.path.relpath(fpath, book_dir)
                print(f'BROKEN {attr}: "{raw_url}" in {rel_source} (no file at {target})')
                failures += 1
            elif attr == "href" and target.endswith(".html"):
                with open(target, encoding="utf-8", errors="replace") as target_file:
                    target_content = target_file.read()
                if re.search(r'<meta\s+http-equiv=["\']refresh["\']', target_content, re.IGNORECASE):
                    rel_source = os.path.relpath(fpath, book_dir)
                    rel_target = os.path.relpath(target, book_dir)
                    print(f'LEGACY href: "{raw_url}" in {rel_source} points to redirect stub {rel_target}')
                    failures += 1

print()
print(f"checked {checked} links/images, {failures} broken")
sys.exit(1 if failures else 0)
PYEOF
