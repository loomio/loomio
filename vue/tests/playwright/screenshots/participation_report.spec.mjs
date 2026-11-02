import { test, expect } from '../screenshotFixtures.mjs';

  // The Oatmilk scenario supplies representative activity at three levels
  // across several months for this overview.

test('participation_report_graph', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_participation_report');
  await page.waitFor('.report-page');
  await page.expectText('.report-page', 'Participation report');
  await page.expectText('.report-page', 'Production');
  await page.expectText('.report-page', 'Cafe partnerships');
  await page.expectText('.report-page', 'Operations');
  await screenshot.captureRegion(
    'groups/participation_report/group_participation_report_graph',
    ['.report-page > h1', '.report-activity-chart'],
    {
    padding: 12,
    width: 1100,
    height: 1300
    }
  );
});

test('participation_report_tags', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_participation_report');
  await page.waitFor('.report-tags-per-interval');
  await page.expectText('.report-tags-per-interval', 'Production');
  await page.expectText('.report-tags-per-interval', 'Cafe partnerships');
  await page.expectText('.report-tags-per-interval', 'Operations');
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_tags',
    '.report-tags-per-interval',
    { width: 1100, height: 1100 }
  );
});

test('participation_report_actions_per_user', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_participation_report');
  await page.waitFor('.report-actions-per-user');
  await page.click('.report-actions-per-user .v-checkbox .v-selection-control');
  await page.expectText('.report-actions-per-user', 'Samira Patel');
  await page.expectText('.report-actions-per-user', 'Alex Morgan');
  await page.expectText('.report-actions-per-user', 'Taylor Reed');
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_actions_per_user',
    '.report-actions-per-user',
    { width: 1100, height: 1000 }
  );
  await page.expectText('.report-voting-record', 'Votes issued');
  await page.expectText('.report-voting-record', 'Votes missed');
  await page.expectText('.report-voting-record', 'All votes cast');
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_voting_record',
    '.report-voting-record',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_users_per_country', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_participation_report');
  await page.waitFor('.report-users-per-country');
  await page.expectText('.report-users-per-country', 'New Zealand');
  await page.expectText('.report-users-per-country', 'Australia');
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_users_per_country',
    '.report-users-per-country',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_actions_per_country', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_participation_report');
  await page.waitFor('.report-actions-per-country');
  await page.expectText('.report-actions-per-country', 'New Zealand');
  await page.expectText('.report-actions-per-country', 'Australia');
  await page.expectText('.report-actions-per-country', 'Canada');
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_actions_per_country',
    '.report-actions-per-country',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_action', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-dock .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--group_stats');
  await page.expectText('.v-overlay .action-dock__button--group_stats', 'Participation report');
  await screenshot.capture('groups/participation_report/group_participation_report', {
    spotlight: {
      selector: '.v-overlay .action-dock__button--group_stats',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});
