const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

function openDirectDiscussions(page) {
  page.loadPath('setup_manual_oatmilk_direct_discussions');
  page.waitFor('.topics-page');
  page.expectText('.topics-page', 'Cafe bottle collection check-in');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'direct_discussion_example': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDirectDiscussions(page);
    page.click('.topics-page__new-topic-button');
    page.waitFor('.discussion-templates--direct-discussion');
    page.click('.discussion-templates--direct-discussion');
    page.waitFor('.discussion-form');
    page.fillIn('.discussion-form__title-input input', 'Cafe bottle collection planning');
    page.fillRichText('.discussion-form .ProseMirror', richText.context('direct-discussion', [
      'Use this direct discussion to confirm collection dates for the six-week bottle trial.',
      'Samira will check washing capacity while Jamie confirms the driver schedule and crate storage.',
      'Record any change that cafe staff need to know before the first delivery.'
    ]));
    page.fillIn('.recipients-autocomplete input', 'Samira');
    page.waitFor('.recipients-autocomplete-suggestion');
    page.execute("Array.from(document.querySelectorAll('.recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Samira Patel')).click()");
    page.expectText('.recipients-autocomplete', 'Samira Patel');
    page.click('.discussion-form__title-input input');
    screenshot.captureElement('discussions/direct_discussions/direct-discussion-example', '.discussion-form', {
      width: 1100,
      height: 1400
    });
  },

  'direct_discussion_sidebar': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDirectDiscussions(page);
    page.ensureSidebar();
    screenshot.capture('discussions/direct_discussions/direct-discussion-sidebar', {
      spotlight: {
        selector: '.sidebar__list-item-button--private',
        padding: 10,
        radius: 12
      },
      width: 1280,
      height: 900
    });
  }
};
