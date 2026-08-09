const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'report_overview': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_participation_report');
    page.waitFor('.report-page');
    page.expectText('.report-page', 'Participation report');
    page.expectText('.report-page', 'Oatmilk Cooperative');
    page.waitFor('.report-page canvas');
    page.pause(500);
    screenshot.captureElement('groups/participation_report/group_participation_report_graph', '.report-page', {
      height: 1300
    });
  },

  'participation_report_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-dock .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--group_stats');
    page.expectText('.v-overlay .action-dock__button--group_stats', 'Participation report');
    screenshot.capture('groups/participation_report/group_participation_report', {
      spotlight: {
        selector: '.v-overlay .action-dock__button--group_stats',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  }
};
