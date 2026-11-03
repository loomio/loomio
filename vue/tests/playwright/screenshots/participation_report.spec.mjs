import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

  // The Oatmilk scenario supplies representative activity at three levels
  // across several months for this overview.

test('participation_report_graph', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_participation_report')
  await expect(page.locator('.report-page').first()).toBeVisible()
  await expectLabel(page.locator('.report-page'), 'Participation report')
  await expectLabel(page.locator('.report-page'), 'Production')
  await expectLabel(page.locator('.report-page'), 'Cafe partnerships')
  await expectLabel(page.locator('.report-page'), 'Operations')
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

test('participation_report_tags', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_participation_report')
  await expect(page.locator('.report-tags-per-interval').first()).toBeVisible()
  await expectLabel(page.locator('.report-tags-per-interval'), 'Production')
  await expectLabel(page.locator('.report-tags-per-interval'), 'Cafe partnerships')
  await expectLabel(page.locator('.report-tags-per-interval'), 'Operations')
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_tags',
    '.report-tags-per-interval',
    { width: 1100, height: 1100 }
  );
});

test('participation_report_actions_per_user', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_participation_report')
  await expect(page.locator('.report-actions-per-user').first()).toBeVisible()
  await page.locator('.report-actions-per-user .v-checkbox .v-selection-control').click()
  await expectLabel(page.locator('.report-actions-per-user'), 'Samira Patel')
  await expectLabel(page.locator('.report-actions-per-user'), 'Alex Morgan')
  await expectLabel(page.locator('.report-actions-per-user'), 'Taylor Reed')
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_actions_per_user',
    '.report-actions-per-user',
    { width: 1100, height: 1000 }
  );
  await expectLabel(page.locator('.report-voting-record'), 'Votes issued')
  await expectLabel(page.locator('.report-voting-record'), 'Votes missed')
  await expectLabel(page.locator('.report-voting-record'), 'All votes cast')
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_voting_record',
    '.report-voting-record',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_users_per_country', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_participation_report')
  await expect(page.locator('.report-users-per-country').first()).toBeVisible()
  await expectLabel(page.locator('.report-users-per-country'), 'New Zealand')
  await expectLabel(page.locator('.report-users-per-country'), 'Australia')
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_users_per_country',
    '.report-users-per-country',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_actions_per_country', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_participation_report')
  await expect(page.locator('.report-actions-per-country').first()).toBeVisible()
  await expectLabel(page.locator('.report-actions-per-country'), 'New Zealand')
  await expectLabel(page.locator('.report-actions-per-country'), 'Australia')
  await expectLabel(page.locator('.report-actions-per-country'), 'Canada')
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_actions_per_country',
    '.report-actions-per-country',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-dock .action-menu--btn').click()
  await expect(page.locator('.v-overlay .action-dock__button--group_stats').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay .action-dock__button--group_stats'), 'Participation report')
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
