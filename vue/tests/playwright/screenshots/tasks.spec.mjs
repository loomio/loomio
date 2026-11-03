import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

const editor = '.comment-form .lmo-textarea';
const proseMirror = `${editor} .ProseMirror`;
let scenarioKey = 100;

async function openTaskEditor(page) {
  scenarioKey += 1;
  await page.goto(`/dev/setup_manual_oatmilk_formatting?key=${scenarioKey}`)
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator(proseMirror).first()).toBeVisible()
  await page.evaluate("const el = document.querySelector('.comment-form .ProseMirror'); el.focus(); el.innerHTML = '<p><br class=\"ProseMirror-trailingBreak\"></p>'; el.dispatchEvent(new InputEvent('input', {bubbles: true, inputType: 'deleteContentBackward'}))")
  await page.locator(`${editor} .html-editor__expand`).click()
  await expect(page.locator(`${editor} .text-editor__task-list`).first()).toBeVisible()
}

async function selectEditorText(page) {
  await page.evaluate("const el = document.querySelector('.comment-form .ProseMirror'); const range = document.createRange(); range.selectNodeContents(el); const selection = window.getSelection(); selection.removeAllRanges(); selection.addRange(range)")
}

async function fillTask(page) {
  await openTaskEditor(page);
  await page.locator(proseMirror).fill('Confirm bottle washer capacity with suppliers')
  await selectEditorText(page);
  await page.locator(`${editor} .text-editor__task-list`).click()
  await expect(page.locator(`${editor} .task-item-text`).first()).toBeVisible()
  await page.evaluate('window.getSelection().removeAllRanges(); document.activeElement.blur()')
}

async function fillAssignedTask(page) {
  await openTaskEditor(page);
  await page.locator(proseMirror).pressSequentially('Confirm bottle washer capacity with suppliers @jamie')
  await expect(page.locator('.suggestion-list [data-mention-handle="jamiechen"] .v-list-item-title').first()).toBeAttached()
  await page.locator('.suggestion-list [data-mention-handle="jamiechen"] .v-list-item-title').click()
  await selectEditorText(page);
  await page.locator(`${editor} .text-editor__task-list`).click()
  await expect(page.locator(`${editor} .task-item-text`).first()).toBeVisible()
  await expect(page.locator(`${editor} .task-item-text + .v-chip`).first()).toBeVisible()
  await page.evaluate('window.getSelection().removeAllRanges(); document.activeElement.blur()')
}

test('tasklist1', async ({ page, manual: screenshot }) => {
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

test('tasklist2', async ({ page, manual: screenshot }) => {
  await fillAssignedTask(page);
  await screenshot.captureRegion('discussions/tasks/tasklist2', [editor], {
    padding: 32,
    width: 1100,
    height: 1200
  });
});

test('task_list', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_tasks')
  await expect(page.locator('.dashboard-page').first()).toBeVisible()
  await expectLabel(page.locator('.dashboard-page'), 'Confirm bottle washer capacity with suppliers')
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

test('taskreminderform', async ({ page, manual: screenshot }) => {
  await fillAssignedTask(page);
  await page.locator(`${editor} .task-item-text + .v-chip`).click()
  await expect(page.locator('.v-dialog .v-card').first()).toBeVisible()
  await screenshot.captureElement('discussions/tasks/taskreminderform', '.v-dialog .v-card', {
    width: 1100,
    height: 1200
  });
});

test('taskdone', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_task_discussion')
  await expect(page.locator('.context-panel__description').first()).toBeVisible()
  await expectLabel(page.locator('.context-panel__description'), 'Share cafe collection dates')
  await screenshot.captureRegion('discussions/tasks/taskdone', ['.context-panel__description'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});
