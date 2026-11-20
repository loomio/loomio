import { readFile } from 'node:fs/promises';
import { test, expect } from '../fixtures.mjs';
import { editor } from '../helpers/editor.mjs';

const file = (name, mimeType, folder = 'media') => readFile(new URL(`../assets/${folder}/${name}`, import.meta.url))
  .then(buffer => ({ name, mimeType, buffer }));
const imageFile = () => file('oatmilk-bottle.png', 'image/png', 'avatars');
const stableBlob = /^\/rails\/active_storage\/blobs\//;
const stableRepresentation = /^\/rails\/active_storage\/representations\//;

async function expectLoaded(media, property) {
  await expect.poll(() => media.evaluate((element, key) => element[key], property)).toBeGreaterThan(0);
}

test('a visual editor draft previews local media and saves stable links after reload', async ({ page }) => {
  await page.goto('/dev/setup_discussion_html_description_edit?text=Draft+media');
  const form = page.locator('.discussion-form');
  const richText = editor(form);
  const image = richText.locator('img');
  const audio = richText.locator('audio');
  const video = richText.locator('video');
  const mediaInput = form.locator('.collab-editor__images-input');

  for (const [source, element, property] of [
    [await imageFile(), image, 'naturalWidth'],
    [await file('tone.webm', 'audio/webm'), audio, 'readyState'],
    [await file('blue.webm', 'video/webm'), video, 'videoWidth']
  ]) {
    await mediaInput.setInputFiles(source);
    await expect(element).toHaveAttribute('src', /^blob:/);
    await expectLoaded(element, property);
  }

  await page.reload();
  await expect(image).toHaveAttribute('src', stableRepresentation);
  const unsavedUrl = await image.getAttribute('src');
  expect((await page.request.get(unsavedUrl)).status()).toBe(404);

  await form.locator('.discussion-form__submit').click();
  const description = page.locator('.context-panel__description');
  await expect(description.locator('img')).toHaveAttribute('src', stableRepresentation);

  await page.reload();
  await expect(description.locator('img')).toHaveAttribute('src', stableRepresentation);
  await expectLoaded(description.locator('img'), 'naturalWidth');
  await expect(description.locator('audio')).toHaveAttribute('src', stableBlob);
  await expectLoaded(description.locator('audio'), 'readyState');
  await expect(description.locator('video')).toHaveAttribute('src', stableBlob);
  await expectLoaded(description.locator('video'), 'videoWidth');
  await expect(description.locator('[src^="blob:"]')).toHaveCount(0);
});

test('the Markdown editor previews uploads locally and saves the same stable links', async ({ page }) => {
  await page.goto('/dev/setup_discussion');
  await page.locator('.context-panel .action-dock__button--edit_thread').click();
  const form = page.locator('.discussion-form');
  const textarea = form.locator('.lmo-textarea textarea');
  await textarea.fill('Markdown file preview');

  const image = await imageFile();
  const dataTransfer = await page.evaluateHandle(({ name, mimeType, bytes }) => {
    const transfer = new DataTransfer();
    transfer.items.add(new File([new Uint8Array(bytes)], name, { type: mimeType }));
    return transfer;
  }, { name: image.name, mimeType: image.mimeType, bytes: Array.from(image.buffer) });
  await textarea.dispatchEvent('drop', { dataTransfer });
  await expect(textarea).toHaveValue(/\/rails\/active_storage\/representations\//);

  await form.locator('.md-editor__files-input').setInputFiles({ ...image, name: 'attachment.png' });
  const attachment = form.locator('.files-list');
  await expect(attachment.locator('.files-list__file-name')).toHaveAttribute('href', /^blob:/);
  await expectLoaded(attachment.locator('img'), 'naturalWidth');

  await form.locator('.md-editor__preview').click();
  const inlinePreview = form.locator('.lmo-markdown-wrapper img');
  await expect(inlinePreview).toHaveAttribute('src', /^blob:/);
  await expectLoaded(inlinePreview, 'naturalWidth');
  await form.locator('.discussion-form__submit').click();

  const description = page.locator('.context-panel__description');
  await expect(description.locator('img')).toHaveAttribute('src', stableRepresentation);
  await page.reload();
  await expectLoaded(description.locator('img'), 'naturalWidth');
  await expect(description.locator('img')).toHaveAttribute('src', stableRepresentation);
  const link = page.locator('a[href^="/rails/active_storage/blobs/"]', { hasText: 'attachment.png' });
  await expect(link).toHaveCount(1);
  expect((await page.request.get(await link.getAttribute('href'))).ok()).toBe(true);
});
