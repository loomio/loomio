import { test, expect } from '../fixtures.mjs';

const editor = '.comment-form .ProseMirror';
const textarea = '.comment-form .lmo-textarea textarea';

test('switches_modes_without_losing_structure_or_markdown_edits', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion');
  await page.expectElement(editor);
  await page.fillRichText(editor, '<p><span style="color: red">Keep this text</span> <span data-mention-id="jennifergrey" data-label="Jennifer Grey">@Jennifer Grey</span></p><table><tbody><tr><th>Name</th><th>Vote</th></tr><tr><td>Alice</td><td>Yes</td></tr></tbody></table><ul data-type="taskList"><li data-type="taskItem" data-checked="true"><p>Done</p></li></ul>');
  await page.expectText(editor, 'Keep this text');
  await page.click('.comment-form .html-editor__expand');
  await page.click('.comment-form .e2e-markdown-btn');
  await page.acceptConfirm();
  await page.expectElement(textarea);
  const markdown = await page.first(textarea).inputValue();
  expect(markdown).toContain('Keep this text @jennifergrey');
  expect(markdown).toContain('| Name');
  expect(markdown).toContain('- [x] Done');
  expect(markdown).not.toContain('@null');
  await page.execute(selector => {
    const field = document.querySelector(selector);
    const setValue = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
    setValue.call(field, `${field.value}\n\nEdited in Markdown`);
    field.dispatchEvent(new Event('input', { bubbles: true }));
  }, textarea);
  await page.click('.comment-form .e2e-wysiwyg-btn');
  await page.expectText(editor, 'Edited in Markdown', 10000);
  await page.expectElement(`${editor} table`);
  await page.expectElement(`${editor} span[data-mention-id="jennifergrey"]`);
  await page.expectElement(`${editor} .task-item-text`);
  await page.expectText('.comment-form .mention-notifications-count', '1 person will be notified');
  await page.click('.comment-form__submit-button');
  await page.expectText('.new-comment', 'Edited in Markdown');
  await page.expectElement('.new-comment table');
  await page.expectElement('.new-comment li[data-checked="true"]');
});
