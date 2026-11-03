// The editor of the comment form at the end of a thread.
export function commentEditor(page) {
  return page.locator('.comment-form .ProseMirror');
}

export async function postComment(page, text) {
  await commentEditor(page).fill(text);
  await page.locator('.comment-form__submit-button').click();
}

// The whole thread. Reply threads nest their own lists inside it.
export function thread(page) {
  return page.locator('.topic-list').first();
}

// Runs an action from an item's menu, such as a comment found by its text.
export async function itemAction(page, item, action) {
  await item.locator('.action-menu--btn').click();
  await page.locator(`.v-overlay--active .action-dock__button--${action}`).click();
}
