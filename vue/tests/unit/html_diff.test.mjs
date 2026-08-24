import assert from 'node:assert/strict';
import test from 'node:test';

import htmlDiff from '../../src/shared/helpers/html_diff.js';

test('escapes executable markup when diffing plain text', () => {
  const result = htmlDiff(
    'Safe title',
    '<img src=x onerror=alert(document.domain)>',
    { isText: true }
  );

  assert.equal(result.includes('<img'), false);
  assert.equal(result.includes('&lt;img'), true);
  assert.equal(result.includes('<ins>'), true);
});

test('escapes unchanged executable markup when diffing plain text', () => {
  const title = '<svg/onload=alert(document.domain)>';

  assert.equal(
    htmlDiff(title, title, { isText: true }),
    '&lt;svg/onload=alert(document.domain)&gt;'
  );
});

test('preserves plain-text title characters as visible text', () => {
  const result = htmlDiff(
    'Research & development',
    'Research & development <draft>',
    { isText: true }
  );

  assert.equal(result, 'Research &amp; development<ins> &lt;draft&gt;</ins>');
});

test('preserves trusted markup for rich-text diffs', () => {
  assert.equal(
    htmlDiff('<p>Original</p>', '<p>Updated</p>'),
    '<p><del>Original</del><ins>Updated</ins></p>'
  );
});
