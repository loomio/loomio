import { test, expect } from '../fixtures.mjs';
import { comment, itemAction, postComment } from '../helpers/threads.mjs';

test('saves, lists and removes a bookmark', async ({ page, flash }) => {
  await page.goto('/dev/setup_discussion');
  await postComment(page, 'a comment worth bookmarking');
  await itemAction(page, comment(page, 'a comment worth bookmarking'), 'save_bookmark');
  await expect(flash).toContainText('Bookmark saved');

  await page.goto('/bookmarks');
  const bookmark = page.locator('.bookmarks-page__bookmark');
  await expect(bookmark).toContainText('What star sign are you?');
  await expect(bookmark).toContainText('Comment by Patrick Swayze');
  await bookmark.locator('.bookmarks-page__remove').click();
  await expect(flash).toContainText('Bookmark removed');
  await expect(bookmark).toHaveCount(0);
});
