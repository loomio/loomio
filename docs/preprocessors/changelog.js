#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const CHANGELOG_INDEX_PATH = "user_manual/changelog/index.md";
const CHANGELOG_ENTRY_PATTERN = /^\d{4}-\d{2}-\d{2}_.+\.md$/;

if (process.argv[2] === "supports") {
  process.exit(process.argv[3] === "html" ? 0 : 1);
}

const [context, book] = JSON.parse(fs.readFileSync(0, "utf8"));
const sourceRoot = path.resolve(context.root, context.config.book.src);
const changelogRoot = path.join(sourceRoot, path.dirname(CHANGELOG_INDEX_PATH));
const indexContent = fs.readFileSync(path.join(sourceRoot, CHANGELOG_INDEX_PATH), "utf8").trimEnd();

const entryNames = fs.readdirSync(changelogRoot)
  .filter((name) => CHANGELOG_ENTRY_PATTERN.test(name))
  .sort()
  .reverse();

if (entryNames.length === 0) {
  throw new Error(`No changelog entries found in ${changelogRoot}`);
}

const entryContent = entryNames.map((name) => {
  const dateIso = name.slice(0, 10);
  const [year, month, day] = dateIso.split("-").map(Number);
  const date = new Intl.DateTimeFormat("en-US", {
    day: "numeric",
    month: "long",
    timeZone: "UTC",
    year: "numeric",
  }).format(new Date(Date.UTC(year, month - 1, day)));
  const markdown = fs.readFileSync(path.join(changelogRoot, name), "utf8").trim();

  return `<p class="changelog-date"><time datetime="${dateIso}">${date}</time></p>\n\n${markdown}`;
}).join("\n\n");

let indexFound = false;

function updateItems(items) {
  for (const item of items) {
    const chapter = item.Chapter;
    if (!chapter) continue;

    if (chapter.source_path === CHANGELOG_INDEX_PATH) {
      chapter.content = `${indexContent}\n\n${entryContent}\n`;
      indexFound = true;
    }

    updateItems(chapter.sub_items || []);
  }
}

updateItems(book.sections || book.items || []);

if (!indexFound) {
  throw new Error(`${CHANGELOG_INDEX_PATH} is missing from SUMMARY.md`);
}

process.stdout.write(JSON.stringify(book));
