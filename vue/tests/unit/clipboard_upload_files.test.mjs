import assert from 'node:assert/strict';
import test from 'node:test';

import { clipboardUploadFiles } from '../../src/shared/helpers/clipboard_upload_files.mjs';

test('pasting an image with whitespace text uploads only the image', async () => {
  const image = new File(['image data'], 'image.png', { type: 'image/png' });
  const clipboardData = {
    items: [
      { getAsFile: () => null },
      { getAsFile: () => image }
    ],
    getData: () => ' '
  };

  const uploads = clipboardUploadFiles(clipboardData);

  assert.equal(uploads.length, 1);
  assert.match(uploads[0].name, /^\d+$/);
  assert.equal(uploads[0].type, 'image/png');
  assert.equal(await uploads[0].text(), 'image data');
});

test('pasting text without a file does not create an upload', () => {
  const clipboardData = {
    items: [{ getAsFile: () => null }],
    getData: () => 'Text'
  };

  assert.deepEqual(clipboardUploadFiles(clipboardData), []);
});
