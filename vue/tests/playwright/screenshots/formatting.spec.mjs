import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import { fileURLToPath } from 'node:url';

const editor = '.comment-form .lmo-textarea';
const proseMirror = `${editor} .ProseMirror`;
const sampleImage = fileURLToPath(new URL('../assets/avatars/oatmilk-bottle.png', import.meta.url));
const sampleFile = fileURLToPath(new URL('../assets/oatmilk-bottle-trial.md', import.meta.url));
let scenarioKey = 0;

async function openEditor(page, expanded = false) {
  scenarioKey += 1;
  await page.goto(`/dev/setup_manual_oatmilk_formatting?key=${scenarioKey}`)
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator(proseMirror).first()).toBeVisible()
  await page.evaluate("const el = document.querySelector('.comment-form .ProseMirror'); el.focus(); el.innerHTML = '<p><br class=\"ProseMirror-trailingBreak\"></p>'; el.dispatchEvent(new InputEvent('input', {bubbles: true, inputType: 'deleteContentBackward'}))")
  if (expanded) {
    await page.locator(`${editor} .html-editor__expand`).click()
    await expect(page.locator(`${editor} .text-editor__heading1`).first()).toBeVisible()
  }
}

async function fillAndSelect(page, text) {
  await page.locator(proseMirror).fill(text)
  await page.evaluate("const el = document.querySelector('.comment-form .ProseMirror'); const range = document.createRange(); range.selectNodeContents(el); const selection = window.getSelection(); selection.removeAllRanges(); selection.addRange(range)")
}

async function captureEditor(screenshot, name, options = {}) {
  await screenshot.captureRegion(`discussions/formatting/${name}`, [editor], {
    width: 1100,
    height: 1200,
    padding: 32,
    ...options
  });
}

async function spotlightButton(screenshot, name, buttonClass) {
  await captureEditor(screenshot, name, {
    spotlight: {
      selector: `${editor} .${buttonClass}`,
      padding: 10,
      radius: 12
    }
  });
}

async function prepareUploadInputs(page) {
  await page.evaluate("const inputs = document.querySelectorAll('.comment-form .lmo-textarea input[type=file]'); inputs.forEach(input => { input.classList.remove('d-none'); input.style.display = 'block'; input.style.position = 'fixed'; input.style.left = '8px'; input.style.bottom = '8px'; input.style.zIndex = '1'; }); inputs[0].classList.add('manual-file-input'); inputs[1].classList.add('manual-image-input')")
}

test('thread_format_bar', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.locator(proseMirror).fill('Outline the returnable bottle trial for the cafe partners.')
  await captureEditor(screenshot, 'thread_format_bar');
});

test('format_attach', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await spotlightButton(screenshot, 'format_attach', 'text-editor__attach');
});

test('thread_file_remove', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await prepareUploadInputs(page);
  await page.locator('.manual-file-input').first().setInputFiles(sampleFile);
  await expect(page.locator(`${editor} .files-list`).first()).toBeVisible()
  await screenshot.captureRegion('discussions/formatting/thread_file_remove', [`${editor} .files-list`], {
    width: 1100,
    height: 1000,
    padding: 32
  });
});

test('format_insert_image', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await spotlightButton(screenshot, 'format_insert_image', 'text-editor__insert-image');
});

test('format_insert_example', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await prepareUploadInputs(page);
  await page.locator('.manual-image-input').first().setInputFiles(sampleImage);
  await expect(page.locator(`${proseMirror} img`).first()).toBeVisible({ timeout: 15000 })
  await captureEditor(screenshot, 'format_insert_example');
});

test('format_image_example', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await prepareUploadInputs(page);
  await page.locator('.manual-image-input').first().setInputFiles(sampleImage);
  await expect(page.locator(`${proseMirror} img`).first()).toBeVisible({ timeout: 15000 })
  await page.locator('.comment-form__submit-button').click()
  await expect(page.locator('.new-comment .new-comment__body img').first()).toBeVisible({ timeout: 15000 })
  await page.evaluate("Array.from(document.querySelectorAll('.new-comment')).find(el => el.querySelector('.new-comment__body img')).classList.add('manual-image-comment')")
  await screenshot.captureRegion('discussions/formatting/format_image_example', ['.manual-image-comment'], {
    width: 1100,
    height: 1200,
    padding: 32
  });
});

test('format_link', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await fillAndSelect(page, 'Cafe bottle return guide');
  await page.locator(`${editor} .text-editor__link`).click()
  await expect(page.locator('.v-overlay--active input[type=url]').first()).toBeVisible()
  await screenshot.captureRegion('discussions/formatting/format_link', [
    editor,
    '.v-overlay--active .v-card'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_insert_emoji', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await page.locator(`${editor} .emoji-picker__toggle`).click()
  await expect(page.locator('.v-overlay--active .emoji-picker').first()).toBeVisible()
  await screenshot.captureRegion('discussions/formatting/thread_insert_emoji', [
    editor,
    '.v-overlay--active .emoji-picker'
  ], {padding: 32, width: 1100, height: 1400});
});

test('format_heading', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Returnable bottle trial');
  await page.locator(`${editor} .text-editor__heading2`).click()
  await spotlightButton(screenshot, 'format_heading', 'text-editor__heading2');
});

test('format_bold', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Important cleaning requirements');
  await page.locator(`${editor} .text-editor__bold`).click()
  await spotlightButton(screenshot, 'format_bold', 'text-editor__bold');
});

test('thread_bullets', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cleaning process\nReturn tracking\nCafe feedback');
  await page.locator(`${editor} .text-editor__bullet-list`).click()
  await spotlightButton(screenshot, 'thread_bullets', 'text-editor__bullet-list');
});

test('format_numbers', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Confirm cafe partners\nDeliver bottles\nReview return rates');
  await page.locator(`${editor} .text-editor__number-list`).click()
  await spotlightButton(screenshot, 'format_numbers', 'text-editor__number-list');
});

test('format_tasks', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Confirm collection dates\nDocument cleaning time\nReview transport costs');
  await page.locator(`${editor} .text-editor__task-list`).click()
  await spotlightButton(screenshot, 'format_tasks', 'text-editor__task-list');
});

test('thread_colors', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cleaning time needs review');
  await page.locator(`${editor} .text-editor__colors`).click()
  await expect(page.locator('.v-overlay--active .color-picker').first()).toBeVisible()
  await screenshot.captureRegion('discussions/formatting/thread_colors', [
    editor,
    '.v-overlay--active .color-picker'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_align', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.locator(proseMirror).fill('Returnable bottle trial')
  await page.locator(`${editor} .text-editor__alignment`).click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await screenshot.captureRegion('discussions/formatting/thread_align', [
    editor,
    '.v-overlay--active .v-list'
  ], {padding: 32, width: 1100, height: 1200});
});

test('format_embed', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.locator(`${editor} .text-editor__embed`).click()
  await page.locator('.v-overlay--active input[type=url]').fill('https://www.youtube.com/watch?v=AJnjTd9u4zg')
  await screenshot.captureRegion('discussions/formatting/format_embed', [
    editor,
    '.v-overlay--active .v-card'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_quote', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cafe partners need collection dates before the trial starts.');
  await page.locator(`${editor} .text-editor__blockquote`).click()
  await spotlightButton(screenshot, 'thread_quote', 'text-editor__blockquote');
});

test('thread_codeblock', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'returned_bottles / delivered_bottles');
  await page.locator(`${editor} .text-editor__code-block`).click()
  await spotlightButton(screenshot, 'thread_codeblock', 'text-editor__code-block');
});

test('thread_line', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.locator(proseMirror).fill('Trial goals')
  await page.locator(`${editor} .text-editor__divider`).click()
  await page.locator(proseMirror).fill('Collection schedule')
  await spotlightButton(screenshot, 'thread_line', 'text-editor__divider');
});

test('thread_table', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.locator(`${editor} .text-editor__add-table`).click()
  await expect(page.locator(`${proseMirror} table`).first()).toBeVisible()
  await spotlightButton(screenshot, 'thread_table', 'text-editor__add-table');
});
