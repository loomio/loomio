import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { comment } from '../helpers/threads.mjs';

test('save_bookmark', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  const bookmarked = comment(page, 'three cafes');
  await bookmarked.locator('.action-menu--btn').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--save_bookmark')).toBeVisible()
  // Captures take CSS selectors, which cannot match text, so mark the comment.
  // Mark it after opening the menu, which re-renders the comment.
  await bookmarked.evaluate(element => element.classList.add('manual-bookmark-comment'))
  await screenshot.captureRegion(
    'users/bookmarks/save_bookmark',
    ['.manual-bookmark-comment', '.v-overlay--active .v-list'],
    {
      width: 1100,
      height: 1500,
      padding: 16,
      spotlight: {
        selector: '.v-overlay--active .action-dock__button--save_bookmark',
        padding: 16,
        radius: 16,
        opacity: 0.4,
        outlineWidth: 0
      }
    }
  );
});

test('bookmarks_page', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_bookmarks')
  // Translated runs only wait for the labels' elements, so wait for the list.
  await expect(page.locator('.bookmarks-page__bookmark').first()).toBeVisible()
  await expectLabel(page.locator('.bookmarks-page'), 'Returnable bottles for cafe customers')
  await expectLabel(page.locator('.bookmarks-page'), 'Run a six-week returnable bottle trial')
  await screenshot.captureElement('users/bookmarks/bookmarks_page', '.bookmarks-page', {
    width: 1100,
    height: 1800
  });
});
