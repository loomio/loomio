import { test, expect } from '../fixtures.mjs';

test('admins_can_save_the_attachment_checkbox_in_thread_settings', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.topic-sidebar .action-dock__button--thread_settings').click()
  await expect(page.locator('.topic-arrangement-form')).toContainText('Only admins can add attachments')
  await expect(page.locator('.topic-arrangement-form .v-card-item__append .help-link').first()).toHaveAttribute('href', /\/en\/user_manual\/discussions\/using_discussions#thread-settings/);
  await expect(page.locator('.topic-arrangement-form .v-card-item__append .help-link')).toContainText('Help')
  await expect(page.locator('.topic-arrangement-form .topic-settings__single-poll input').first()).not.toBeChecked();
  await page.locator('.topic-settings__attachments-admin-only label').click()
  await page.locator('.topic-arrangement-form .v-card-actions button').click()
  await expect(page.locator('.flash-root__message')).toContainText('Discussion updated')
  await page.reload()
  await page.locator('.topic-sidebar .action-dock__button--thread_settings').click()
  await expect(page.locator('.topic-settings__attachments-admin-only input').first()).toBeChecked();
});

test('members_can_post_text_without_attachment_controls_in_restricted_threads', async ({ page }) => {
  await page.goto('/dev/setup_attachment_restricted_discussion')
  await expect(page.locator('.comment-form .ProseMirror')).toBeVisible()
  await expect(page.locator('.comment-form .text-editor__attach')).toHaveCount(0)
  await expect(page.locator('.comment-form .text-editor__insert-image')).toHaveCount(0)
  await page.locator('.comment-form .ProseMirror').fill('My text contribution')
  await page.locator('.comment-form__submit-button').click()
  await expect(page.locator('.new-comment')).toContainText('My text contribution')
});
