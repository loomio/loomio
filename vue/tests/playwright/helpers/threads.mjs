import { editor } from './editor.mjs';

// The comment form at the end of a thread, and the form that opens when
// replying to an item.
export const commentForm = page => page.locator('.add-comment-panel .comment-form');
export const replyForm = page => page.locator('.reply-form .comment-form');

export async function postComment(page, text, form = commentForm(page)) {
  await editor(form).fill(text);
  await form.locator('.comment-form__submit-button').click();
}

// A comment in the thread, found by its text.
export function comment(page, text) {
  return page.locator('.new-comment', { hasText: text });
}

// The whole thread. Reply threads nest their own lists inside it.
export function thread(page) {
  return page.locator('.topic-list').first();
}

// Runs an action from an item's menu, such as a comment's.
export async function itemAction(page, item, action) {
  await item.locator('.action-menu--btn').click();
  await page.locator(`.v-overlay--active .action-dock__button--${action}`).click();
}

// Types a mention into an editor and picks the person from the suggestions.
export async function mention(page, input, query, handle) {
  await input.pressSequentially(query);
  await page.locator(`.suggestion-list [data-mention-handle="${handle}"]`).click();
}

// Opens the new thread form from a group page, from a discussion template
// (config/discussion_templates.yml key).
export async function openThreadForm(page, template = 'blank') {
  await page.locator('.discussions-panel__new-topic-button').click();
  await page.locator(`.discussion-templates--template-${template}`).click();
}
