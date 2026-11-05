import { test, expect } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { commentForm } from '../helpers/threads.mjs';

import { fileURLToPath } from 'node:url';

// Capture selectors are CSS strings for the capture helper.
const textarea = '.comment-form .lmo-textarea';
const sampleImage = fileURLToPath(new URL('../assets/avatars/oatmilk-bottle.png', import.meta.url));
const sampleFile = fileURLToPath(new URL('../assets/oatmilk-bottle-trial.md', import.meta.url));
let scenarioKey = 0;

const input = page => editor(commentForm(page));
const button = (page, name) => commentForm(page).locator(`.text-editor__${name}`);

// Each test uses its own thread, so drafts from other tests stay out.
async function openEditor(page, expanded = false) {
  scenarioKey += 1;
  await page.goto(`/dev/setup_manual_oatmilk_formatting?key=${scenarioKey}`);
  await input(page).fill('');
  if (expanded) {
    await commentForm(page).locator('.html-editor__expand').click();
    await expect(button(page, 'heading1')).toBeVisible();
  }
}

async function fillAndSelect(page, text) {
  await input(page).fill(text);
  await input(page).selectText();
}

async function captureEditor(screenshot, name, options = {}) {
  await screenshot.captureRegion(`discussions/formatting/${name}`, [textarea], {
    width: 1100,
    height: 1200,
    padding: 32,
    ...options
  });
}

async function spotlightButton(screenshot, name, buttonClass) {
  await captureEditor(screenshot, name, {
    spotlight: {
      selector: `${textarea} .${buttonClass}`,
      padding: 10,
      radius: 12
    }
  });
}

async function attachFile(page, file) {
  await commentForm(page).locator('.collab-editor__files-input').setInputFiles(file);
}

async function insertImage(page, file) {
  await commentForm(page).locator('.collab-editor__images-input').setInputFiles(file);
  await expect(input(page).locator('img')).toBeVisible();
}

test('thread_format_bar', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await input(page).fill('Outline the returnable bottle trial for the cafe partners.');
  await captureEditor(screenshot, 'thread_format_bar');
});

test('format_attach', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await spotlightButton(screenshot, 'format_attach', 'text-editor__attach');
});

test('thread_file_remove', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await attachFile(page, sampleFile);
  await expect(commentForm(page).locator('.files-list')).toBeVisible();
  await screenshot.captureRegion('discussions/formatting/thread_file_remove', [`${textarea} .files-list`], {
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
  await insertImage(page, sampleImage);
  await captureEditor(screenshot, 'format_insert_example');
});

test('format_image_example', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await insertImage(page, sampleImage);
  await commentForm(page).locator('.comment-form__submit-button').click();
  const imageComment = '.new-comment:has(.new-comment__body img)';
  await expect(page.locator(imageComment)).toBeVisible();
  await screenshot.captureRegion('discussions/formatting/format_image_example', [imageComment], {
    width: 1100,
    height: 1200,
    padding: 32
  });
});

test('format_link', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await fillAndSelect(page, 'Cafe bottle return guide');
  await button(page, 'link').click();
  await expect(page.locator('.v-overlay--active input[type=url]')).toBeVisible();
  await screenshot.captureRegion('discussions/formatting/format_link', [
    textarea,
    '.v-overlay--active .v-card'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_insert_emoji', async ({ page, manual: screenshot }) => {
  await openEditor(page);
  await commentForm(page).locator('.emoji-picker__toggle').click();
  await expect(page.locator('.v-overlay--active .emoji-picker')).toBeVisible();
  await screenshot.captureRegion('discussions/formatting/thread_insert_emoji', [
    textarea,
    '.v-overlay--active .emoji-picker'
  ], {padding: 32, width: 1100, height: 1400});
});

test('format_heading', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Returnable bottle trial');
  await button(page, 'heading2').click();
  await spotlightButton(screenshot, 'format_heading', 'text-editor__heading2');
});

test('format_bold', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Important cleaning requirements');
  await button(page, 'bold').click();
  await spotlightButton(screenshot, 'format_bold', 'text-editor__bold');
});

test('thread_bullets', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cleaning process\nReturn tracking\nCafe feedback');
  await button(page, 'bullet-list').click();
  await spotlightButton(screenshot, 'thread_bullets', 'text-editor__bullet-list');
});

test('format_numbers', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Confirm cafe partners\nDeliver bottles\nReview return rates');
  await button(page, 'number-list').click();
  await spotlightButton(screenshot, 'format_numbers', 'text-editor__number-list');
});

test('format_tasks', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Confirm collection dates\nDocument cleaning time\nReview transport costs');
  await button(page, 'task-list').click();
  await spotlightButton(screenshot, 'format_tasks', 'text-editor__task-list');
});

test('thread_colors', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cleaning time needs review');
  await button(page, 'colors').click();
  await expect(page.locator('.v-overlay--active .color-picker')).toBeVisible();
  await screenshot.captureRegion('discussions/formatting/thread_colors', [
    textarea,
    '.v-overlay--active .color-picker'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_align', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await input(page).fill('Returnable bottle trial');
  await button(page, 'alignment').click();
  await expect(page.locator('.v-overlay--active .v-list')).toBeVisible();
  await screenshot.captureRegion('discussions/formatting/thread_align', [
    textarea,
    '.v-overlay--active .v-list'
  ], {padding: 32, width: 1100, height: 1200});
});

test('format_embed', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await button(page, 'embed').click();
  await page.locator('.v-overlay--active input[type=url]').fill('https://www.youtube.com/watch?v=AJnjTd9u4zg');
  await screenshot.captureRegion('discussions/formatting/format_embed', [
    textarea,
    '.v-overlay--active .v-card'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_quote', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cafe partners need collection dates before the trial starts.');
  await button(page, 'blockquote').click();
  await spotlightButton(screenshot, 'thread_quote', 'text-editor__blockquote');
});

test('thread_codeblock', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'returned_bottles / delivered_bottles');
  await button(page, 'code-block').click();
  await spotlightButton(screenshot, 'thread_codeblock', 'text-editor__code-block');
});

test('thread_line', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await input(page).fill('Trial goals');
  await button(page, 'divider').click();
  await input(page).fill('Collection schedule');
  await spotlightButton(screenshot, 'thread_line', 'text-editor__divider');
});

test('thread_table', async ({ page, manual: screenshot }) => {
  await openEditor(page, true);
  await button(page, 'add-table').click();
  await expect(input(page).locator('table')).toBeVisible();
  await spotlightButton(screenshot, 'thread_table', 'text-editor__add-table');
});
