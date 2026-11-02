import { test, expect } from '../fixtures.mjs';

test('restricted_member_can_start_a_thread_with_template_tags', async ({ page }) => {
  await page.goto('/dev/setup_member_discussion_with_restricted_tags')
  await expect(page.locator('.tags-field__input.v-autocomplete')).toBeVisible()
  await expect(page.locator('.tags-field__input .v-chip')).toContainText('Existing')
  await expect(page.locator('.tags-field__input')).toContainText('Template default')
  await page.fill('#discussion-title', 'Thread with existing tags')
  await page.fill('.tags-field__input input:not([type="hidden"])', 'Other')
  await page.click('.v-overlay--active .v-list-item')
  await expect(page.locator('.tags-field__input')).toContainText('Other')
  await page.fill('.tags-field__input input:not([type="hidden"])', 'Unauthorized new tag')
  await page.locator('.tags-field__input input:not([type="hidden"])').first().press('Enter');
  await page.click('#discussion-title')
  await expect(page.locator('.tags-field__input .v-chip')).not.toContainText('Unauthorized new tag')
  await page.click('.discussion-form__submit')
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
