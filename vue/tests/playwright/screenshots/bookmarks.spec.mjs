import { test, expect } from '../screenshotFixtures.mjs';

test('save_bookmark', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.new-comment');
  await page.execute(`
    const comment = Array.from(document.querySelectorAll('.new-comment'))
      .find((element) => element.textContent.includes('three cafes'));
    comment.classList.add('manual-bookmark-comment');
    comment.querySelector('.action-menu--btn').click();
  `);
  await page.waitFor('.v-overlay--active .action-dock__button--save_bookmark');
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

test('bookmarks_page', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_bookmarks');
  await page.waitFor('.bookmarks-page .v-list-item');
  await page.expectText('.bookmarks-page', 'Returnable bottles for cafe customers');
  await page.expectText('.bookmarks-page', 'Run a six-week returnable bottle trial');
  await screenshot.captureElement('users/bookmarks/bookmarks_page', '.bookmarks-page', {
    width: 1100,
    height: 1800
  });
});
