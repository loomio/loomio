import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

test('save_bookmark', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.new-comment').first()).toBeVisible()
  await page.evaluate(`
    const comment = Array.from(document.querySelectorAll('.new-comment'))
      .find((element) => element.textContent.includes('three cafes'));
    comment.classList.add('manual-bookmark-comment');
    comment.querySelector('.action-menu--btn').click();
  `)
  await expect(page.locator('.v-overlay--active .action-dock__button--save_bookmark').first()).toBeVisible()
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
  await expect(page.locator('.bookmarks-page .v-list-item').first()).toBeVisible()
  await expectLabel(page.locator('.bookmarks-page'), 'Returnable bottles for cafe customers')
  await expectLabel(page.locator('.bookmarks-page'), 'Run a six-week returnable bottle trial')
  await screenshot.captureElement('users/bookmarks/bookmarks_page', '.bookmarks-page', {
    width: 1100,
    height: 1800
  });
});
