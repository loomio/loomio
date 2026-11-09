import { test, expect } from '../fixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { comment, commentForm } from '../helpers/threads.mjs';

// Content that is hard to type: coloured text, a mention, a table and a task.
const richContent = '<p><span style="color: red">Keep this text</span> <span data-mention-id="jennifergrey" data-label="Jennifer Grey">@Jennifer Grey</span></p>' +
  '<table><tbody><tr><th>Name</th><th>Vote</th></tr><tr><td>Alice</td><td>Yes</td></tr></tbody></table>' +
  '<ul data-type="taskList"><li data-type="taskItem" data-checked="true"><p>Done</p></li></ul>';

test('switching between rich text and Markdown keeps structure and Markdown edits', async ({ page }) => {
  await page.goto('/dev/setup_discussion');
  const form = commentForm(page);
  const richText = editor(form);
  const markdown = form.locator('.lmo-textarea textarea');

  await richText.evaluate((element, html) => {
    element.innerHTML = html;
    element.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }));
  }, richContent);
  await expect(richText).toContainText('Keep this text');

  await form.locator('.html-editor__expand').click();
  await form.locator('.e2e-markdown-btn').click();
  await expect(markdown).toHaveValue(/Keep this text @jennifergrey/);
  await expect(markdown).toHaveValue(/\| Name/);
  await expect(markdown).toHaveValue(/- \[x\] Done/);
  await expect(markdown).not.toHaveValue(/@null/);
  await markdown.fill(`${await markdown.inputValue()}\n\nEdited in Markdown`);

  await form.locator('.e2e-wysiwyg-btn').click();
  await expect(richText).toContainText('Edited in Markdown');
  await expect(richText.locator('table')).toBeVisible();
  await expect(richText.locator('[data-mention-id="jennifergrey"]')).toBeVisible();
  await expect(richText.locator('.task-item-text')).toBeVisible();
  await expect(form.locator('.mention-notifications-count')).toContainText('1 person will be notified');

  await form.locator('.comment-form__submit-button').click();
  const posted = comment(page, 'Edited in Markdown');
  await expect(posted.locator('table')).toBeVisible();
  await expect(posted.locator('li[data-checked="true"]')).toBeVisible();
});
