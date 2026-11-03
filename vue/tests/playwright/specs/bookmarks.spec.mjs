import { test, expect } from '../fixtures.mjs';

test('can_save_view_and_remove_a_bookmark', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').fill('a comment worth bookmarking')
  await page.locator('.comment-form__submit-button').click()
  await expect(page.locator('.flash-root__message')).toContainText('Comment added')
  await page.locator('.new-comment', { hasText: 'a comment worth bookmarking' }).locator('.action-menu--btn').click()
  await expect(page.locator('.action-dock__button--save_bookmark')).toBeVisible()
  await page.locator('.action-dock__button--save_bookmark:visible').click()
  await expect(page.locator('.flash-root__message')).toContainText('Bookmark saved')

  await page.goto('/bookmarks')
  await expect(page.locator('.bookmarks-page')).toContainText('What star sign are you?')
  await expect(page.locator('.bookmarks-page')).toContainText('Comment by Patrick Swayze')

  await page.locator('.bookmarks-page button[title="Remove bookmark"]').click()
  await expect(page.locator('.flash-root__message')).toContainText('Bookmark removed')
  await expect(page.locator('.bookmarks-page .v-list-item')).toHaveCount(0)
});
