const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  // The Oatmilk scenario supplies representative activity at three levels
  // across several months for this overview.

  'participation_report_graph': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_participation_report');
    page.waitFor('.report-page');
    page.expectText('.report-page', 'Participation report');
    page.expectText('.report-page', 'Production');
    page.expectText('.report-page', 'Cafe partnerships');
    page.expectText('.report-page', 'Operations');
    screenshot.captureRegion(
      'groups/participation_report/group_participation_report_graph',
      ['.report-page > h1', '.report-activity-chart'],
      {
      padding: 12,
      width: 1100,
      height: 1300
      }
    );
  },

  'participation_report_tags': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_participation_report');
    page.waitFor('.report-tags-per-interval');
    page.expectText('.report-tags-per-interval', 'Production');
    page.expectText('.report-tags-per-interval', 'Cafe partnerships');
    page.expectText('.report-tags-per-interval', 'Operations');
    screenshot.captureElement(
      'groups/participation_report/group_participation_report_tags',
      '.report-tags-per-interval',
      { width: 1100, height: 1100 }
    );
  },

  'participation_report_actions_per_user': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_participation_report');
    page.waitFor('.report-actions-per-user');
    page.click('.report-actions-per-user .v-checkbox .v-selection-control');
    page.expectText('.report-actions-per-user', 'Samira Patel');
    page.expectText('.report-actions-per-user', 'Alex Morgan');
    page.expectText('.report-actions-per-user', 'Taylor Reed');
    screenshot.captureElement(
      'groups/participation_report/group_participation_report_actions_per_user',
      '.report-actions-per-user',
      { width: 1100, height: 1000 }
    );
    page.expectText('.report-voting-record', 'Votes issued');
    page.expectText('.report-voting-record', 'Votes missed');
    page.expectText('.report-voting-record', 'All votes cast');
    screenshot.captureElement(
      'groups/participation_report/group_participation_report_voting_record',
      '.report-voting-record',
      { width: 1100, height: 1000 }
    );
  },

  'participation_report_users_per_country': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_participation_report');
    page.waitFor('.report-users-per-country');
    page.expectText('.report-users-per-country', 'New Zealand');
    page.expectText('.report-users-per-country', 'Australia');
    screenshot.captureElement(
      'groups/participation_report/group_participation_report_users_per_country',
      '.report-users-per-country',
      { width: 1100, height: 1000 }
    );
  },

  'participation_report_actions_per_country': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_participation_report');
    page.waitFor('.report-actions-per-country');
    page.expectText('.report-actions-per-country', 'New Zealand');
    page.expectText('.report-actions-per-country', 'Australia');
    page.expectText('.report-actions-per-country', 'Canada');
    screenshot.captureElement(
      'groups/participation_report/group_participation_report_actions_per_country',
      '.report-actions-per-country',
      { width: 1100, height: 1000 }
    );
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
