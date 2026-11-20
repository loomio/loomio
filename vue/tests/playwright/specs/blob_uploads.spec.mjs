import { readFile } from 'node:fs/promises';
import { test, expect } from '../fixtures.mjs';
import { editor } from '../helpers/editor.mjs';

const file = (name, mimeType, folder = 'media') => readFile(new URL(`../assets/${folder}/${name}`, import.meta.url))
  .then(buffer => ({ name, mimeType, buffer }));
const imageFile = () => file('oatmilk-bottle.png', 'image/png', 'avatars');
const stableBlob = /^\/rails\/active_storage\/blobs\//;
const draftJpeg = /^data:image\/jpeg;base64,/;
const stableRepresentation = /^\/rails\/active_storage\/representations\//;

async function expectLoaded(media, property) {
  await expect.poll(() => media.evaluate((element, key) => element[key], property)).toBeGreaterThan(0);
}

async function dropImage(page, textarea, image) {
  const dataTransfer = await page.evaluateHandle(({ name, mimeType, bytes }) => {
    const transfer = new DataTransfer();
    transfer.items.add(new File([new Uint8Array(bytes)], name, { type: mimeType }));
    return transfer;
  }, { name: image.name, mimeType: image.mimeType, bytes: Array.from(image.buffer) });
  await textarea.dispatchEvent('drop', { dataTransfer });
}

test('a collaborator previews a resized image before the thread is saved', async ({ page, browser }) => {
  await page.goto('/dev/setup_discussion_html_description_edit?text=Draft+media');
  const form = page.locator('.discussion-form');
  const richText = editor(form);
  const image = richText.locator('img');
  const audio = richText.locator('audio');
  const video = richText.locator('video');
  const mediaInput = form.locator('.collab-editor__images-input');

  const collaborator = await browser.newPage({
    storageState: await page.context().storageState()
  });
  try {
    await collaborator.goto(page.url());
    await expect(collaborator.locator('.discussion-form .collab-editor--server-synced')).toBeVisible();

    const imageUpload = page.waitForResponse(response => new URL(response.url()).pathname === '/direct_uploads' &&
      response.request().method() === 'POST' && response.ok());
    for (const [source, element, property, src] of [
      [await imageFile(), image, 'naturalWidth', draftJpeg],
      [await file('tone.webm', 'audio/webm'), audio, 'readyState', /^blob:/],
      [await file('blue.webm', 'video/webm'), video, 'videoWidth', /^blob:/]
    ]) {
      await mediaInput.setInputFiles(source);
      await expect(element).toHaveAttribute('src', src);
      await expectLoaded(element, property);
    }

    const { preview_url: unsavedUrl } = await (await imageUpload).json();
    const imageRequests = [];
    const recordImageRequest = request => {
      if (new URL(request.url()).pathname === unsavedUrl) imageRequests.push(request.url());
    };
    page.on('request', recordImageRequest);
    collaborator.on('request', recordImageRequest);
    const sharedImage = editor(collaborator.locator('.discussion-form')).locator('img');
    await expect(sharedImage).toHaveAttribute('src', draftJpeg);
    await expectLoaded(sharedImage, 'naturalWidth');
    const previewUrl = await sharedImage.getAttribute('src');
    expect(previewUrl.length).toBeLessThanOrEqual(256 * 1024);
    const [width, height] = await sharedImage.evaluate(element => [element.naturalWidth, element.naturalHeight]);
    expect(Math.max(width, height)).toBeLessThanOrEqual(1024);
    expect(width / height).toBeCloseTo(1448 / 1086, 2);

    await page.reload();
    await expect(image).toHaveAttribute('src', draftJpeg);
    await expectLoaded(image, 'naturalWidth');
    expect(imageRequests).toEqual([]);
    expect((await page.request.get(unsavedUrl)).status()).toBe(404);

    const saving = page.waitForRequest(request => request.method() === 'PATCH' &&
      new URL(request.url()).pathname.startsWith('/api/v1/discussions/'));
    await form.locator('.discussion-form__submit').click();
    const { discussion: { description: savedHtml } } = (await saving).postDataJSON();
    expect(savedHtml).toContain(unsavedUrl);
    expect(savedHtml).not.toMatch(/(?:blob:|data:image\/)/);
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
  } finally {
    await collaborator.close();
  }
});

test('the Markdown editor previews uploads locally and saves the same stable links', async ({ page }) => {
  await page.goto('/dev/setup_discussion');
  await page.locator('.context-panel .action-dock__button--edit_thread').click();
  const form = page.locator('.discussion-form');
  const textarea = form.locator('.lmo-textarea textarea');
  await textarea.fill('Markdown file preview');

  const image = await imageFile();
  await dropImage(page, textarea, image);
  await expect(textarea).toHaveValue(/\/rails\/active_storage\/representations\//);

  await form.locator('.md-editor__files-input').setInputFiles({ ...image, name: 'attachment.png' });
  const attachment = form.locator('.files-list');
  await expect(attachment.locator('.files-list__file-name')).toHaveAttribute('href', /^blob:/);
  await expectLoaded(attachment.locator('img'), 'naturalWidth');

  await form.locator('.md-editor__preview').click();
  const inlinePreview = form.locator('.lmo-markdown-wrapper img');
  await expect(inlinePreview).toHaveAttribute('src', draftJpeg);
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

test('draft images survive visual and Markdown conversion in both directions', async ({ page }) => {
  await page.goto('/dev/setup_discussion_html_description_edit?text=Draft+conversion');
  const form = page.locator('.discussion-form');
  const richText = editor(form);
  const textarea = form.locator('.lmo-textarea textarea');
  const visualUpload = { ...await imageFile(), name: 'original (draft).png' };
  await form.locator('.collab-editor__images-input').setInputFiles(visualUpload);
  await expect(richText.locator('img')).toHaveAttribute('src', draftJpeg);

  await form.locator('.html-editor__expand').click();
  await form.locator('.e2e-markdown-btn').click();
  await expect(textarea).toHaveValue(/!\[.*\]\(\/rails\/active_storage\/representations\//);
  await expect(textarea).not.toHaveValue(/data:image/);
  const togglePreview = form.locator('.md-editor__preview');
  await togglePreview.click();
  await expectLoaded(form.locator('.lmo-markdown-wrapper img[src^="data:image/jpeg"]'), 'naturalWidth');
  await togglePreview.click();

  await dropImage(page, textarea, { ...await imageFile(), name: 'second-upload.png' });
  await expect(textarea).toHaveValue(/!\[seconduploadpng\]\(\/rails\/active_storage\/representations\//);
  await form.locator('.e2e-wysiwyg-btn').click();
  await expect(richText.locator('img[src^="data:image/jpeg"]')).toHaveCount(2);

  await form.locator('.discussion-form__submit').click();
  const description = page.locator('.context-panel__description');
  const savedImages = description.locator('img[src^="/rails/active_storage/representations/"]');
  await expect(savedImages).toHaveCount(2);
  await expect.poll(() => savedImages.evaluateAll(images => images.every(image => image.naturalWidth > 0))).toBe(true);
  await expect(description.locator('img[src^="data:"]')).toHaveCount(0);
});
