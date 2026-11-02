import { test, expect } from '../screenshotFixtures.mjs';

import { fileURLToPath } from 'node:url';

const editor = '.comment-form .lmo-textarea';
const proseMirror = `${editor} .ProseMirror`;
const sampleImage = fileURLToPath(new URL('../assets/avatars/oatmilk-bottle.png', import.meta.url));
const sampleFile = fileURLToPath(new URL('../assets/oatmilk-bottle-trial.md', import.meta.url));
let scenarioKey = 0;

async function openEditor(page, expanded = false) {
  scenarioKey += 1;
  await page.loadPath(`setup_manual_oatmilk_formatting?key=${scenarioKey}`);
  await page.waitFor('.topic-page');
  await page.waitFor(proseMirror);
  await page.execute("const el = document.querySelector('.comment-form .ProseMirror'); el.focus(); el.innerHTML = '<p><br class=\"ProseMirror-trailingBreak\"></p>'; el.dispatchEvent(new InputEvent('input', {bubbles: true, inputType: 'deleteContentBackward'}))");
  await page.pause(200);
  if (expanded) {
    await page.click(`${editor} .html-editor__expand`);
    await page.waitFor(`${editor} .text-editor__heading1`);
  }
}

async function fillAndSelect(page, text) {
  await page.fillIn(proseMirror, text);
  await page.execute("const el = document.querySelector('.comment-form .ProseMirror'); const range = document.createRange(); range.selectNodeContents(el); const selection = window.getSelection(); selection.removeAllRanges(); selection.addRange(range)");
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
  await page.execute("const inputs = document.querySelectorAll('.comment-form .lmo-textarea input[type=file]'); inputs.forEach(input => { input.classList.remove('d-none'); input.style.display = 'block'; input.style.position = 'fixed'; input.style.left = '8px'; input.style.bottom = '8px'; input.style.zIndex = '1'; }); inputs[0].classList.add('manual-file-input'); inputs[1].classList.add('manual-image-input')");
}

test('thread_format_bar', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.fillIn(proseMirror, 'Outline the returnable bottle trial for the cafe partners.');
  await captureEditor(screenshot, 'thread_format_bar');
});

test('format_attach', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page);
  await spotlightButton(screenshot, 'format_attach', 'text-editor__attach');
});

test('thread_file_remove', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page);
  await prepareUploadInputs(page);
  await page.first('.manual-file-input').setInputFiles(sampleFile);
  await page.waitFor(`${editor} .files-list`);
  await screenshot.captureRegion('discussions/formatting/thread_file_remove', [`${editor} .files-list`], {
    width: 1100,
    height: 1000,
    padding: 32
  });
});

test('format_insert_image', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page);
  await spotlightButton(screenshot, 'format_insert_image', 'text-editor__insert-image');
});

test('format_insert_example', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page);
  await prepareUploadInputs(page);
  await page.first('.manual-image-input').setInputFiles(sampleImage);
  await page.waitFor(`${proseMirror} img`, 15000);
  await captureEditor(screenshot, 'format_insert_example');
});

test('format_image_example', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page);
  await prepareUploadInputs(page);
  await page.first('.manual-image-input').setInputFiles(sampleImage);
  await page.waitFor(`${proseMirror} img`, 15000);
  await page.click('.comment-form__submit-button');
  await page.waitFor('.new-comment .new-comment__body img', 15000);
  await page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.querySelector('.new-comment__body img')).classList.add('manual-image-comment')");
  await screenshot.captureRegion('discussions/formatting/format_image_example', ['.manual-image-comment'], {
    width: 1100,
    height: 1200,
    padding: 32
  });
});

test('format_link', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page);
  await fillAndSelect(page, 'Cafe bottle return guide');
  await page.click(`${editor} .text-editor__link`);
  await page.waitFor('.v-overlay--active input[type=url]');
  await screenshot.captureRegion('discussions/formatting/format_link', [
    editor,
    '.v-overlay--active .v-card'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_insert_emoji', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page);
  await page.click(`${editor} .emoji-picker__toggle`);
  await page.waitFor('.v-overlay--active .emoji-picker');
  await screenshot.captureRegion('discussions/formatting/thread_insert_emoji', [
    editor,
    '.v-overlay--active .emoji-picker'
  ], {padding: 32, width: 1100, height: 1400});
});

test('format_heading', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Returnable bottle trial');
  await page.click(`${editor} .text-editor__heading2`);
  await spotlightButton(screenshot, 'format_heading', 'text-editor__heading2');
});

test('format_bold', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Important cleaning requirements');
  await page.click(`${editor} .text-editor__bold`);
  await spotlightButton(screenshot, 'format_bold', 'text-editor__bold');
});

test('thread_bullets', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cleaning process\nReturn tracking\nCafe feedback');
  await page.click(`${editor} .text-editor__bullet-list`);
  await spotlightButton(screenshot, 'thread_bullets', 'text-editor__bullet-list');
});

test('format_numbers', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Confirm cafe partners\nDeliver bottles\nReview return rates');
  await page.click(`${editor} .text-editor__number-list`);
  await spotlightButton(screenshot, 'format_numbers', 'text-editor__number-list');
});

test('format_tasks', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Confirm collection dates\nDocument cleaning time\nReview transport costs');
  await page.click(`${editor} .text-editor__task-list`);
  await spotlightButton(screenshot, 'format_tasks', 'text-editor__task-list');
});

test('thread_colors', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cleaning time needs review');
  await page.click(`${editor} .text-editor__colors`);
  await page.waitFor('.v-overlay--active .color-picker');
  await screenshot.captureRegion('discussions/formatting/thread_colors', [
    editor,
    '.v-overlay--active .color-picker'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_align', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.fillIn(proseMirror, 'Returnable bottle trial');
  await page.click(`${editor} .text-editor__alignment`);
  await page.waitFor('.v-overlay--active .v-list');
  await screenshot.captureRegion('discussions/formatting/thread_align', [
    editor,
    '.v-overlay--active .v-list'
  ], {padding: 32, width: 1100, height: 1200});
});

test('format_embed', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.click(`${editor} .text-editor__embed`);
  await page.waitFor('.v-overlay--active input[type=url]');
  await page.fillIn('.v-overlay--active input[type=url]', 'https://www.youtube.com/watch?v=AJnjTd9u4zg');
  await screenshot.captureRegion('discussions/formatting/format_embed', [
    editor,
    '.v-overlay--active .v-card'
  ], {padding: 32, width: 1100, height: 1200});
});

test('thread_quote', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'Cafe partners need collection dates before the trial starts.');
  await page.click(`${editor} .text-editor__blockquote`);
  await spotlightButton(screenshot, 'thread_quote', 'text-editor__blockquote');
});

test('thread_codeblock', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await fillAndSelect(page, 'returned_bottles / delivered_bottles');
  await page.click(`${editor} .text-editor__code-block`);
  await spotlightButton(screenshot, 'thread_codeblock', 'text-editor__code-block');
});

test('thread_line', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.fillIn(proseMirror, 'Trial goals');
  await page.click(`${editor} .text-editor__divider`);
  await page.fillIn(proseMirror, 'Collection schedule');
  await spotlightButton(screenshot, 'thread_line', 'text-editor__divider');
});

test('thread_table', async ({ lmo: page, manual: screenshot }) => {
  await openEditor(page, true);
  await page.click(`${editor} .text-editor__add-table`);
  await page.waitFor(`${proseMirror} table`);
  await spotlightButton(screenshot, 'thread_table', 'text-editor__add-table');
});
