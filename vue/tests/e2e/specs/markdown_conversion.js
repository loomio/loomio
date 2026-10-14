const pageHelper = require('../helpers/pageHelper');

const editor = '.comment-form .ProseMirror';
const textarea = '.comment-form .lmo-textarea textarea';

module.exports = {
  'switches_modes_without_losing_structure_or_markdown_edits': test => {
    const page = pageHelper(test);
    page.loadPath('setup_discussion');
    page.expectElement(editor);
    page.fillRichText(editor, '<p><span style="color: red">Keep this text</span> <span data-mention-id="jennifergrey" data-label="Jennifer Grey">@Jennifer Grey</span></p><table><tbody><tr><th>Name</th><th>Vote</th></tr><tr><td>Alice</td><td>Yes</td></tr></tbody></table><ul data-type="taskList"><li data-type="taskItem" data-checked="true"><p>Done</p></li></ul>');
    page.expectText(editor, 'Keep this text');
    page.click('.comment-form .html-editor__expand');
    page.click('.comment-form .e2e-markdown-btn');
    page.acceptConfirm();
    page.expectElement(textarea);
    test.getValue(textarea, result => {
      test.assert.ok(result.value.includes('Keep this text @jennifergrey'), result.value);
      test.assert.ok(result.value.includes('| Name'), result.value);
      test.assert.ok(result.value.includes('- [x] Done'), result.value);
      test.assert.ok(!result.value.includes('@null'), result.value);
    });
    test.execute(selector => {
      const field = document.querySelector(selector);
      const setValue = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
      setValue.call(field, `${field.value}\n\nEdited in Markdown`);
      field.dispatchEvent(new Event('input', { bubbles: true }));
    }, [textarea]);
    page.click('.comment-form .e2e-wysiwyg-btn');
    page.expectText(editor, 'Edited in Markdown', 10000);
    page.expectElement(`${editor} table`);
    page.expectElement(`${editor} span[data-mention-id="jennifergrey"]`);
    page.expectElement(`${editor} .task-item-text`);
    page.expectText('.comment-form .mention-notifications-count', '1 person will be notified');
    page.click('.comment-form__submit-button');
    page.expectText('.new-comment', 'Edited in Markdown');
    page.expectElement('.new-comment table');
    page.expectElement('.new-comment li[data-checked="true"]');
  },
};
