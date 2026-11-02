import { test, expect } from '../screenshotFixtures.mjs';

const editor = '.comment-form .lmo-textarea';
const proseMirror = `${editor} .ProseMirror`;
let scenarioKey = 100;

async function openTaskEditor(page) {
  scenarioKey += 1;
  await page.loadPath(`setup_manual_oatmilk_formatting?key=${scenarioKey}`);
  await page.waitFor('.topic-page');
  await page.waitFor(proseMirror);
  await page.execute("const el = document.querySelector('.comment-form .ProseMirror'); el.focus(); el.innerHTML = '<p><br class=\"ProseMirror-trailingBreak\"></p>'; el.dispatchEvent(new InputEvent('input', {bubbles: true, inputType: 'deleteContentBackward'}))");
  await page.click(`${editor} .html-editor__expand`);
  await page.waitFor(`${editor} .text-editor__task-list`);
}

async function selectEditorText(page) {
  await page.execute("const el = document.querySelector('.comment-form .ProseMirror'); const range = document.createRange(); range.selectNodeContents(el); const selection = window.getSelection(); selection.removeAllRanges(); selection.addRange(range)");
}

async function fillTask(page) {
  await openTaskEditor(page);
  await page.fillIn(proseMirror, 'Confirm bottle washer capacity with suppliers');
  await selectEditorText(page);
  await page.click(`${editor} .text-editor__task-list`);
  await page.waitFor(`${editor} .task-item-text`);
  await page.execute('window.getSelection().removeAllRanges(); document.activeElement.blur()');
}

async function fillAssignedTask(page) {
  await openTaskEditor(page);
  await page.fillIn(proseMirror, 'Confirm bottle washer capacity with suppliers @jamie');
  await page.waitForPresent('.suggestion-list [data-mention-handle="jamiechen"] .v-list-item-title');
  await page.clickElement('.suggestion-list [data-mention-handle="jamiechen"] .v-list-item-title');
  await selectEditorText(page);
  await page.click(`${editor} .text-editor__task-list`);
  await page.waitFor(`${editor} .task-item-text`);
  await page.waitFor(`${editor} .task-item-text + .v-chip`);
  await page.execute('window.getSelection().removeAllRanges(); document.activeElement.blur()');
}

test('tasklist1', async ({ lmo: page, manual: screenshot }) => {
  await fillTask(page);
  await screenshot.captureRegion('discussions/tasks/tasklist1', [editor], {
    spotlight: {
      selector: `${editor} .text-editor__task-list`,
      padding: 10,
      radius: 12
    },
    padding: 32,
    width: 1100,
    height: 1200
  });
});

test('tasklist2', async ({ lmo: page, manual: screenshot }) => {
  await fillAssignedTask(page);
  await screenshot.captureRegion('discussions/tasks/tasklist2', [editor], {
    padding: 32,
    width: 1100,
    height: 1200
  });
});

test('task_list', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_tasks');
  await page.waitFor('.dashboard-page');
  await page.expectText('.dashboard-page', 'Confirm bottle washer capacity with suppliers');
  await screenshot.capture('discussions/tasks/task_list', {
    spotlight: {
      selector: '.sidenav-left a[href="/tasks"]',
      padding: 10,
      radius: 12
    },
    width: 1280,
    height: 900
  });
});

test('taskreminderform', async ({ lmo: page, manual: screenshot }) => {
  await fillAssignedTask(page);
  await page.click(`${editor} .task-item-text + .v-chip`);
  await page.waitFor('.v-dialog .v-card');
  await screenshot.captureElement('discussions/tasks/taskreminderform', '.v-dialog .v-card', {
    width: 1100,
    height: 1200
  });
});

test('taskdone', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_task_discussion');
  await page.waitFor('.context-panel__description');
  await page.expectText('.context-panel__description', 'Share cafe collection dates');
  await screenshot.captureRegion('discussions/tasks/taskdone', ['.context-panel__description'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});
