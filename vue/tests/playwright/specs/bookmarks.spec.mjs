import { test, expect } from '../fixtures.mjs';

test('can_save_view_and_remove_a_bookmark', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'a comment worth bookmarking')
  await page.click('.comment-form__submit-button')
  await page.expectFlash('Comment added')
  await page.pause()
  await page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('a comment worth bookmarking')).querySelector('.action-menu--btn').click()")
  await page.waitFor('.action-dock__button--save_bookmark')
  await page.execute("Array.from(document.querySelectorAll('.action-dock__button--save_bookmark')).find(el => el.offsetParent).click()")
  await page.expectFlash('Bookmark saved')

  await page.goTo('bookmarks')
  await page.expectText('.bookmarks-page', 'What star sign are you?')
  await page.expectText('.bookmarks-page', 'Comment by Patrick Swayze')

  await page.click('.bookmarks-page button[title="Remove bookmark"]')
  await page.expectFlash('Bookmark removed')
  await page.expectNoElement('.bookmarks-page .v-list-item')
});
