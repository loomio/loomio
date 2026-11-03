import { test, expect } from '../fixtures.mjs';

test('restricted_member_can_start_a_thread_with_template_tags', async ({ page }) => {
  await page.goto('/dev/setup_member_discussion_with_restricted_tags')
  await expect(page.locator('.tags-field__input.v-autocomplete')).toBeVisible()
  await expect(page.locator('.tags-field__input .v-chip')).toContainText('Existing')
  await expect(page.locator('.tags-field__input')).toContainText('Template default')
  await page.locator('#discussion-title').fill('Thread with existing tags')
  await page.locator('.tags-field__input input:not([type="hidden"])').fill('Other')
  await page.locator('.v-overlay--active .v-list-item').click()
  await expect(page.locator('.tags-field__input')).toContainText('Other')
  await page.locator('.tags-field__input input:not([type="hidden"])').fill('Unauthorized new tag')
  await page.locator('.tags-field__input input:not([type="hidden"])').first().press('Enter');
  await page.locator('#discussion-title').click()
  await expect(page.locator('.tags-field__input .v-chip')).not.toContainText('Unauthorized new tag')
  await page.locator('.discussion-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Discussion started')
  await expect(page.locator('.context-panel__heading')).toContainText('Thread with existing tags')
  await expect(page.locator('.tags-display')).toContainText('Existing')
  await expect(page.locator('.tags-display')).toContainText('Other')
  await expect(page.locator('.tags-display')).toContainText('Template default')
  await expect(page.locator('.tags-display')).not.toContainText('Unauthorized new tag')
  await expect(page.locator('.topic-header .tag-color-dot[style*="background-color"]')).toHaveCount(3)
  await page.reload()
  await expect(page.locator('.tags-display')).toContainText('Template default')
});
