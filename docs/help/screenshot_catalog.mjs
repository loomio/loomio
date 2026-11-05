// Discover capture names by running our trusted recipes with navigation and
// browser operations disabled. This also resolves names composed by helpers.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const directory = path.join(root, 'vue/tests/playwright/screenshots');
const namePattern = /^[A-Za-z0-9][A-Za-z0-9/_-]*$/;

// Every helper call returns the stub itself, and awaiting it resolves at once.
// It converts to NaN, so comparisons such as a viewport width check are false.
let stub;
stub = new Proxy(function() { return stub; }, {
  get(target, property) {
    if (property === 'then') return undefined;
    if (property === Symbol.toPrimitive) return () => NaN;
    return stub;
  }
});

const captures = [];
let current;
const screenshot = Object.fromEntries(['capture', 'captureElement', 'captureRegion'].map(method => [method, async name => {
  if (!namePattern.test(name)) throw new Error(`Invalid screenshot name: ${name}`);
  const image = `${name.startsWith('guides/') ? '' : 'user_manual/'}${name}.png`;
  captures.push({ image, ...current });
}]));

for (const spec of fs.readdirSync(directory).filter(name => name.endsWith('.spec.mjs')).sort()) {
  globalThis.__manualScreenshotCatalog = { tests: [] };
  await import(pathToFileURL(path.join(directory, spec)).href);
  for (const { title, run } of globalThis.__manualScreenshotCatalog.tests) {
    current = { spec, testcase: title };
    await run({ page: stub, manual: screenshot });
  }
}

const images = new Map();
for (const capture of captures) {
  // Only approved English assets are eligible. Photos, diagrams and manual
  // captures without a recipe remain shared English images.
  if (!fs.existsSync(path.join(root, 'docs/help/en', capture.image))) continue;
  if (images.has(capture.image)) throw new Error(`Duplicate screenshot recipe: ${capture.image}`);
  images.set(capture.image, capture);
}
process.stdout.write(JSON.stringify([...images.values()]));
