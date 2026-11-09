import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { commentForm } from '../helpers/threads.mjs';

// Capture selectors are CSS strings for the capture helper.
const textarea = '.comment-form .lmo-textarea';
let scenarioKey = 100;

const input = page => editor(commentForm(page));
const taskListButton = page => commentForm(page).locator('.text-editor__task-list');
const taskItem = page => commentForm(page).locator('.task-item-text');
const assignee = page => commentForm(page).locator('.task-item-text + .v-chip');

// Each test uses its own thread, so drafts from other tests stay out.
async function openTaskEditor(page) {
  scenarioKey += 1;
  await page.goto(`/dev/setup_manual_oatmilk_formatting?key=${scenarioKey}`);
  await input(page).fill('');
  await commentForm(page).locator('.html-editor__expand').click();
  await expect(taskListButton(page)).toBeVisible();
}

// Turns the editor's text into a task, then clears the selection so the
// capture shows no highlight.
async function makeTask(page) {
  await input(page).selectText();
  await taskListButton(page).click();
  await expect(taskItem(page)).toBeVisible();
  await page.evaluate(() => { window.getSelection().removeAllRanges(); document.activeElement.blur(); });
}

async function fillTask(page) {
  await openTaskEditor(page);
  await input(page).fill('Confirm bottle washer capacity with suppliers');
  await makeTask(page);
}

async function fillAssignedTask(page) {
  await openTaskEditor(page);
  await input(page).pressSequentially('Confirm bottle washer capacity with suppliers @jamie');
  await page.locator('.suggestion-list [data-mention-handle="jamiechen"]').click();
  await makeTask(page);
  await expect(assignee(page)).toBeVisible();
}

test('tasklist1', async ({ page, manual: screenshot }) => {
  await fillTask(page);
  await screenshot.captureRegion('discussions/tasks/tasklist1', [textarea], {
    spotlight: {
      selector: `${textarea} .text-editor__task-list`,
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
  await screenshot.captureRegion('discussions/tasks/tasklist2', [textarea], {
    padding: 32,
    width: 1100,
    height: 1200
  });
});

test('task_list', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_tasks');
  await expectLabel(page.locator('.dashboard-page'), 'Confirm bottle washer capacity with suppliers');
  await screenshot.capture('discussions/tasks/task_list', {
    spotlight: {
      selector: '.sidenav-left a[href="/tasks"]',
      padding: 10,
      radius: 12
    },
    width: 1280,
    height: 757
  });
});

test('taskreminderform', async ({ page, manual: screenshot }) => {
  await fillAssignedTask(page);
  await assignee(page).click();
  await expect(page.locator('.v-dialog .v-card')).toBeVisible();
  await screenshot.captureElement('discussions/tasks/taskreminderform', '.v-dialog .v-card', {
    width: 1100,
    height: 1200
  });
});

test('taskdone', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_task_discussion');
  await expectLabel(page.locator('.context-panel__description'), 'Share cafe collection dates');
  await screenshot.captureRegion('discussions/tasks/taskdone', ['.context-panel__description'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});
