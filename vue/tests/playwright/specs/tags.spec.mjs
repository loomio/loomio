import { test, expect } from '../fixtures.mjs';

test('a member restricted to existing tags starts a thread with template and existing tags', async ({ page, flash }) => {
  await page.goto('/dev/setup_member_discussion_with_restricted_tags')
  const tags = page.locator('.tags-field__input')
  await expect(tags).toContainText('Existing')
  await expect(tags).toContainText('Template default')

  await page.locator('#discussion-title').fill('Thread with existing tags')
  const tagInput = tags.locator('input:not([type="hidden"])')
  await tagInput.fill('Other')
  await page.locator('.v-overlay--active .v-list-item', { hasText: 'Other' }).click()
  await expect(tags).toContainText('Other')

  // Restricted members cannot create a tag by typing a new name.
  await tagInput.fill('Unauthorized new tag')
  await tagInput.press('Enter')
  await page.locator('#discussion-title').click()
  await expect(tags).not.toContainText('Unauthorized new tag')

  await page.locator('.discussion-form__submit').click()
  await expect(flash).toContainText('Discussion started')
  await expect(page.locator('.context-panel__heading')).toContainText('Thread with existing tags')
  const threadTags = page.locator('.topic-header .tags-display')
  for (const name of ['Existing', 'Other', 'Template default']) {
    await expect(threadTags).toContainText(name)
  }
  await expect(threadTags).not.toContainText('Unauthorized new tag')
  await expect(page.locator('.topic-header .tag-color-dot[style*="background-color"]')).toHaveCount(3)

  await page.reload()
  await expect(threadTags).toContainText('Template default')
});
