import { test, expect } from '../fixtures.mjs';

const editor = '.comment-form .ProseMirror';
const textarea = '.comment-form .lmo-textarea textarea';

test('switches_modes_without_losing_structure_or_markdown_edits', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await expect(page.locator(editor)).toBeVisible()
  await page.locator(editor).evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, '<p><span style="color: red">Keep this text</span> <span data-mention-id="jennifergrey" data-label="Jennifer Grey">@Jennifer Grey</span></p><table><tbody><tr><th>Name</th><th>Vote</th></tr><tr><td>Alice</td><td>Yes</td></tr></tbody></table><ul data-type="taskList"><li data-type="taskItem" data-checked="true"><p>Done</p></li></ul>')
  await expect(page.locator(editor)).toContainText('Keep this text')
  await page.locator('.comment-form .html-editor__expand').click()
  await page.locator('.comment-form .e2e-markdown-btn').click()
  await expect(page.locator(textarea)).toBeVisible()
  const markdown = await page.locator(textarea).first().inputValue();
  expect(markdown).toContain('Keep this text @jennifergrey');
  expect(markdown).toContain('| Name');
  expect(markdown).toContain('- [x] Done');
  expect(markdown).not.toContain('@null');
  await page.evaluate(selector => {
    const field = document.querySelector(selector);
    const setValue = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
    setValue.call(field, `${field.value}\n\nEdited in Markdown`);
    field.dispatchEvent(new Event('input', { bubbles: true }));
  }, textarea)
  await page.locator('.comment-form .e2e-wysiwyg-btn').click()
  await expect(page.locator(editor)).toContainText('Edited in Markdown', { timeout: 10000 })
  await expect(page.locator(`${editor} table`)).toBeVisible()
  await expect(page.locator(`${editor} span[data-mention-id="jennifergrey"]`)).toBeVisible()
  await expect(page.locator(`${editor} .task-item-text`)).toBeVisible()
  await expect(page.locator('.comment-form .mention-notifications-count')).toContainText('1 person will be notified')
  await page.locator('.comment-form__submit-button').click()
  await expect(page.locator('.new-comment')).toContainText('Edited in Markdown')
  await expect(page.locator('.new-comment table')).toBeVisible()
  await expect(page.locator('.new-comment li[data-checked="true"]')).toBeVisible()
});
