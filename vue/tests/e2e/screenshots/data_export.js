const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'export_group_data_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-dock .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--export_data');
    page.expectText('.v-overlay .action-dock__button--export_data', 'Export group data');
    screenshot.capture('groups/data_export/group_export_group_data', {
      spotlight: spotlight('.v-overlay .action-dock__button--export_data')
    });
  },

  'print_thread_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_discussion');
    page.waitFor('.strand-page');
    page.expectText('.strand-page', 'Returnable bottles for cafe customers');
    page.waitFor('.thread-sidebar .action-dock__button--export_thread');
    page.expectText('.thread-sidebar .action-dock__button--export_thread', 'Print');
    screenshot.capture('groups/data_export/discussion_print_discussion', {
      spotlight: spotlight('.thread-sidebar .action-dock__button--export_thread')
    });
  }
};
