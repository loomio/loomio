import { test, expect } from '../fixtures.mjs';
import { comment, commentForm, postComment } from '../helpers/threads.mjs';

async function openThreadSettings(page) {
  await page.locator('.topic-sidebar .action-dock__button--thread_settings').click();
  return page.locator('.topic-arrangement-form');
}

test('an admin limits attachments to admins in thread settings', async ({ page, flash }) => {
  await page.goto('/dev/setup_discussion');
  let settings = await openThreadSettings(page);
  await expect(settings).toContainText('Only admins can add attachments');
  await expect(settings.locator('.topic-arrangement-form__help')).toHaveAttribute('href', /\/en\/user_manual\/discussions\/using_discussions#thread-settings/);
  await expect(settings.locator('.topic-settings__single-poll input')).not.toBeChecked();
  await settings.locator('.topic-settings__attachments-admin-only input').check();
  await settings.locator('.topic-arrangement-form__submit').click();
  await expect(flash).toContainText('Discussion updated');

  await page.reload();
  settings = await openThreadSettings(page);
  await expect(settings.locator('.topic-settings__attachments-admin-only input')).toBeChecked();
});

test('members of a restricted thread post text without attachment buttons', async ({ page }) => {
  await page.goto('/dev/setup_attachment_restricted_discussion');
  await expect(commentForm(page).locator('.ProseMirror')).toBeVisible();
  await expect(commentForm(page).locator('.text-editor__attach')).toHaveCount(0);
  await expect(commentForm(page).locator('.text-editor__insert-image')).toHaveCount(0);
  await postComment(page, 'My text contribution');
  await expect(comment(page, 'My text contribution')).toBeVisible();
});
