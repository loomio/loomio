const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  // group_participation_report_graph.png needs representative multi-year data
  // and is intentionally captured manually from a suitable real group.

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
