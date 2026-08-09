const path = require('node:path');
const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

const editor = '.comment-form .lmo-textarea';
const proseMirror = `${editor} .ProseMirror`;
const sampleImage = path.resolve(__dirname, '../../../../public/theme/group_cover_photos/cover4.jpg');
const sampleFile = path.resolve(__dirname, '../fixtures/oatmilk-bottle-trial.md');
let scenarioKey = 0;

function openEditor(page, expanded = false) {
  scenarioKey += 1;
  page.loadPath(`setup_manual_oatmilk_formatting?key=${scenarioKey}`);
  page.waitFor('.strand-page');
  page.waitFor(proseMirror);
  page.execute("const el = document.querySelector('.comment-form .ProseMirror'); el.focus(); el.innerHTML = '<p><br class=\"ProseMirror-trailingBreak\"></p>'; el.dispatchEvent(new InputEvent('input', {bubbles: true, inputType: 'deleteContentBackward'}))");
  page.pause(200);
  if (expanded) {
    page.click(`${editor} .html-editor__expand`);
    page.waitFor(`${editor} button[title="Heading 1"]`);
  }
}

function fillAndSelect(page, text) {
  page.fillIn(proseMirror, text);
  page.execute("const el = document.querySelector('.comment-form .ProseMirror'); const range = document.createRange(); range.selectNodeContents(el); const selection = window.getSelection(); selection.removeAllRanges(); selection.addRange(range)");
}

function captureEditor(screenshot, name, options = {}) {
  screenshot.captureElement(`discussions/formatting/${name}`, editor, {
    width: 1100,
    height: 1200,
    ...options
  });
}

function spotlightButton(screenshot, name, title) {
  captureEditor(screenshot, name, {
    spotlight: {
      selector: `${editor} button[title="${title}"]`,
      padding: 10,
      radius: 12
    }
  });
}

function prepareUploadInputs(page) {
  page.execute("const inputs = document.querySelectorAll('.comment-form .lmo-textarea input[type=file]'); inputs.forEach(input => { input.classList.remove('d-none'); input.style.display = 'block'; input.style.position = 'fixed'; input.style.left = '8px'; input.style.bottom = '8px'; input.style.zIndex = '1'; }); inputs[0].classList.add('manual-file-input'); inputs[1].classList.add('manual-image-input')");
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'thread_format_bar': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    page.fillIn(proseMirror, 'Outline the returnable bottle trial for the cafe partners.');
    captureEditor(screenshot, 'thread_format_bar');
  },

  'format_attach': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page);
    spotlightButton(screenshot, 'format_attach', 'Attach file');
  },

  'thread_file_remove': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page);
    prepareUploadInputs(page);
    test.setValue('.manual-file-input', sampleFile);
    page.waitFor(`${editor} .files-list`);
    screenshot.captureElement('discussions/formatting/thread_file_remove', `${editor} .files-list`, {
      width: 1100,
      height: 1000
    });
  },

  'format_insert_image': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page);
    spotlightButton(screenshot, 'format_insert_image', 'Insert image');
  },

  'format_insert_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page);
    prepareUploadInputs(page);
    test.setValue('.manual-image-input', sampleImage);
    page.waitFor(`${proseMirror} img`, 15000);
    captureEditor(screenshot, 'format_insert_example');
  },

  'format_image_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page);
    prepareUploadInputs(page);
    test.setValue('.manual-image-input', sampleImage);
    page.waitFor(`${proseMirror} img`, 15000);
    page.click('.comment-form__submit-button');
    page.waitFor('.new-comment .new-comment__body img', 15000);
    page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.querySelector('.new-comment__body img')).classList.add('manual-image-comment')");
    screenshot.captureElement('discussions/formatting/format_image_example', '.manual-image-comment', {
      width: 1100,
      height: 1200
    });
  },

  'format_link': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page);
    fillAndSelect(page, 'Cafe bottle return guide');
    page.click(`${editor} button[title="Insert link"]`);
    page.waitFor('.v-overlay--active input[type=url]');
    screenshot.captureRegion('discussions/formatting/format_link', [
      editor,
      '.v-overlay--active .v-card'
    ], {padding: 12, width: 1100, height: 1200});
  },

  'thread_insert_emoji': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page);
    page.click(`${editor} button[title="Insert emoji"]`);
    page.waitFor('.v-overlay--active .emoji-picker');
    screenshot.captureRegion('discussions/formatting/thread_insert_emoji', [
      editor,
      '.v-overlay--active .emoji-picker'
    ], {padding: 12, width: 1100, height: 1400});
  },

  'format_heading': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'Returnable bottle trial');
    page.click(`${editor} button[title="Heading 2"]`);
    spotlightButton(screenshot, 'format_heading', 'Heading 2');
  },

  'format_bold': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'Important cleaning requirements');
    page.click(`${editor} button[title="Bold"]`);
    spotlightButton(screenshot, 'format_bold', 'Bold');
  },

  'thread_bullets': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'Cleaning process\nReturn tracking\nCafe feedback');
    page.click(`${editor} button[title="List"]`);
    spotlightButton(screenshot, 'thread_bullets', 'List');
  },

  'format_numbers': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'Confirm cafe partners\nDeliver bottles\nReview return rates');
    page.click(`${editor} button[title="Numbered list"]`);
    spotlightButton(screenshot, 'format_numbers', 'Numbered list');
  },

  'format_tasks': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'Confirm collection dates\nDocument cleaning time\nReview transport costs');
    page.click(`${editor} button[title="Task list"]`);
    spotlightButton(screenshot, 'format_tasks', 'Task list');
  },

  'thread_colors': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'Cleaning time needs review');
    page.click(`${editor} button[title="Colors"]`);
    page.waitFor('.v-overlay--active .color-picker');
    screenshot.captureRegion('discussions/formatting/thread_colors', [
      editor,
      '.v-overlay--active .color-picker'
    ], {padding: 12, width: 1100, height: 1200});
  },

  'thread_align': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    page.fillIn(proseMirror, 'Returnable bottle trial');
    page.click(`${editor} button[title="Alignment"]`);
    page.waitFor('.v-overlay--active .v-list');
    screenshot.captureRegion('discussions/formatting/thread_align', [
      editor,
      '.v-overlay--active .v-list'
    ], {padding: 12, width: 1100, height: 1200});
  },

  'format_embed': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    page.click(`${editor} button[title="Embed video"]`);
    page.waitFor('.v-overlay--active input[type=url]');
    page.fillIn('.v-overlay--active input[type=url]', 'https://www.youtube.com/watch?v=AJnjTd9u4zg');
    screenshot.captureRegion('discussions/formatting/format_embed', [
      editor,
      '.v-overlay--active .v-card'
    ], {padding: 12, width: 1100, height: 1200});
  },

  'thread_quote': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'Cafe partners need collection dates before the trial starts.');
    page.click(`${editor} button[title="Quote"]`);
    spotlightButton(screenshot, 'thread_quote', 'Quote');
  },

  'thread_codeblock': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    fillAndSelect(page, 'returned_bottles / delivered_bottles');
    page.click(`${editor} button[title="Code block"]`);
    spotlightButton(screenshot, 'thread_codeblock', 'Code block');
  },

  'thread_line': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    page.fillIn(proseMirror, 'Trial goals');
    page.click(`${editor} button[title="Divider"]`);
    page.fillIn(proseMirror, 'Collection schedule');
    spotlightButton(screenshot, 'thread_line', 'Divider');
  },

  'thread_table': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openEditor(page, true);
    page.click(`${editor} button[title="Add table"]`);
    page.waitFor(`${proseMirror} table`);
    spotlightButton(screenshot, 'thread_table', 'Add table');
  }
};
