const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

function imageWithFallbacks(sources, origin = 'https://private.example') {
  const listeners = new Map();
  const image = {
    dataset: {screenshotSources: JSON.stringify(sources)},
    addEventListener(name, callback) { listeners.set(name, callback); },
    removeEventListener(name) { listeners.delete(name); }
  };
  const document = {
    documentElement: {dataset: {}},
    querySelector() { return null; },
    querySelectorAll(selector) { return selector === 'img[data-screenshot-sources]' ? [image] : []; },
    addEventListener() {}
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../../docs/docs.js'), 'utf8'), {
    document, URL, window: {location: {href: `${origin}/docs/fr/example`}}
  });
  return {image, fail() { listeners.get('error')?.(); }, listeners};
}

const local = '/docs-screenshots/fr/example.png';
const hosted = `https://www.loomio.com${local}`;
const english = '/docs/en/example.png';

test('tries local, hosted, then English and updates the 2x source at every step', () => {
  const {image, fail, listeners} = imageWithFallbacks([local, hosted, english]);
  assert.equal(image.src, `https://private.example${local}`);
  assert.equal(image.srcset, `${image.src} 2x`);
  fail();
  assert.equal(image.src, hosted);
  assert.equal(image.srcset, `${hosted} 2x`);
  fail();
  assert.equal(image.src, `https://private.example${english}`);
  assert.equal(image.srcset, `${image.src} 2x`);
  fail();
  assert.equal(listeners.size, 0);
});

test('a supplied local image takes priority and successful loads keep that choice', () => {
  const supplied = '/docs/fr/example.png';
  const {image} = imageWithFallbacks([supplied, local, hosted, english]);
  assert.equal(image.src, `https://private.example${supplied}`);
});

test('loomio.com does not retry the same missing image as a hosted fallback', () => {
  const {image, fail} = imageWithFallbacks([local, hosted, english], 'https://www.loomio.com');
  assert.equal(image.src, hosted);
  fail();
  assert.equal(image.src, `https://www.loomio.com${english}`);
});
