const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'group_overview': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    screenshot.capture('groups/oatmilk-cooperative');
  },

  'proposal_discussion': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_discussion');
    page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
    page.click('.strand-item__load-more button');
    page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
    page.ensureSidebar();
    screenshot.capture('discussions/returnable-bottle-trial', {height: 1100});
  }
};
