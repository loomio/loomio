import { test, expect } from '../fixtures.mjs';

test('admins_can_save_the_attachment_checkbox_in_thread_settings', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion');
  await page.click('.topic-sidebar .action-dock__button--thread_settings');
  await page.expectText('.topic-arrangement-form', 'Only admins can add attachments');
  await expect(page.first('.topic-arrangement-form .v-card-item__append .help-link')).toHaveAttribute('href', /\/en\/user_manual\/discussions\/using_discussions#thread-settings/);
  await page.expectText('.topic-arrangement-form .v-card-item__append .help-link', 'Help');
  await expect(page.first('.topic-arrangement-form .topic-settings__single-poll input')).not.toBeChecked();
  await page.click('.topic-settings__attachments-admin-only label');
  await page.click('.topic-arrangement-form .v-card-actions button');
  await page.expectFlash('Discussion updated');
  await page.refreshAndWait();
  await page.click('.topic-sidebar .action-dock__button--thread_settings');
  await expect(page.first('.topic-settings__attachments-admin-only input')).toBeChecked();
});

test('members_can_post_text_without_attachment_controls_in_restricted_threads', async ({ lmo: page }) => {
  await page.loadPath('setup_attachment_restricted_discussion');
  await page.expectElement('.comment-form .ProseMirror');
  await page.expectNoElement('.comment-form .text-editor__attach');
  await page.expectNoElement('.comment-form .text-editor__insert-image');
  await page.fillIn('.comment-form .ProseMirror', 'My text contribution');
  await page.click('.comment-form__submit-button');
  await page.expectText('.new-comment', 'My text contribution');
});
