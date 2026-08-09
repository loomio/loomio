const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'save_bookmark': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_discussion');
    page.waitFor('.new-comment');
    page.execute(`
      const comment = Array.from(document.querySelectorAll('.new-comment'))
        .find((element) => element.textContent.includes('three cafes'));
      comment.classList.add('manual-bookmark-comment');
      comment.querySelector('.action-menu--btn').click();
    `);
    page.waitFor('.v-overlay--active .action-dock__button--save_bookmark');
    screenshot.captureRegion(
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
  },

  'bookmarks_page': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_bookmarks');
    page.waitFor('.bookmarks-page .v-list-item');
    page.expectText('.bookmarks-page', 'Returnable bottles for cafe customers');
    page.expectText('.bookmarks-page', 'Run a six-week returnable bottle trial');
    screenshot.captureElement('users/bookmarks/bookmarks_page', '.bookmarks-page', {
      width: 1100,
      height: 1800
    });
  }
};
