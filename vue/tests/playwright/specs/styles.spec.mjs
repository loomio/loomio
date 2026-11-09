import { test, expect } from '../fixtures.mjs';
import { openPollForm } from '../helpers/polls.mjs';
import { editor } from '../helpers/editor.mjs';
import { box } from '../helpers/layout.mjs';
import { commentForm } from '../helpers/threads.mjs';

for (const [width, colorScheme] of [[1000, 'light'], [390, 'dark']]) {
  test(`calendar styles load on demand in the ${colorScheme} ${width}px layout`, async ({ page }, testInfo) => {
    await page.setViewportSize({width, height: 900});
    await page.emulateMedia({colorScheme});
    const calendars = [];
    page.on('request', request => {
      if (/\/VDatePicker-[^/]+\.css/.test(request.url())) calendars.push(request.url());
    });

    await page.goto('/dev/polls/test_discussion');
    await expect(editor(page.locator('.add-comment-panel'))).toBeVisible();
    expect(calendars).toEqual([]);
    await page.screenshot({path: testInfo.outputPath('thread.png'), fullPage: true});

    await openPollForm(page, 'meeting');
    const picker = page.locator('.date-time-picker');
    await expect(picker).toBeVisible();
    expect(calendars.length).toBeGreaterThan(0);
    const rect = await box(picker);
    expect(rect.x).toBeGreaterThanOrEqual(0);
    expect(rect.right).toBeLessThanOrEqual(width);
    await picker.scrollIntoViewIfNeeded();
    await page.screenshot({path: testInfo.outputPath('time-poll-form.png')});
  });
}

test('a task calendar loads when assigning a due date', async ({ page }) => {
  await page.goto('/dev/setup_discussion');
  const form = commentForm(page);
  const input = editor(form);
  await input.pressSequentially('Prepare the agenda @jennifer');
  await page.locator('.suggestion-list [data-mention-handle="jennifergrey"]').click();
  await form.locator('.html-editor__expand').click();
  await input.selectText();
  await form.locator('.text-editor__task-list').click();

  const dueDate = form.locator('.task-item__due-date');
  await dueDate.click();
  await expect(page.locator('.task-item__date-picker')).toBeVisible();
  await page.locator('.task-item__save-date').click();
  await expect(dueDate).toContainText(/\d{4}-\d{2}-\d{2}/);
});
