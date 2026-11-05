import { test, expectLabel } from '../screenshotFixtures.mjs';

// The Oatmilk scenario supplies representative activity at three levels
// across several months for this overview.
const openReport = page => page.goto('/dev/setup_manual_oatmilk_participation_report');

async function expectLabels(locator, labels) {
  for (const label of labels) { await expectLabel(locator, label); }
}

test('participation_report_graph', async ({ page, manual: screenshot }) => {
  await openReport(page);
  await expectLabels(page.locator('.report-page'), ['Participation report', 'Production', 'Cafe partnerships', 'Operations']);
  await screenshot.captureRegion(
    'groups/participation_report/group_participation_report_graph',
    ['.report-page > h1', '.report-activity-chart'],
    { padding: 12, width: 1100, height: 1300 }
  );
});

test('participation_report_tags', async ({ page, manual: screenshot }) => {
  await openReport(page);
  await expectLabels(page.locator('.report-tags-per-interval'), ['Production', 'Cafe partnerships', 'Operations']);
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_tags',
    '.report-tags-per-interval',
    { width: 1100, height: 1100 }
  );
});

test('participation_report_actions_per_user', async ({ page, manual: screenshot }) => {
  await openReport(page);
  await page.locator('.report-actions-per-user__delegates-only input').check();
  await expectLabels(page.locator('.report-actions-per-user'), ['Samira Patel', 'Alex Morgan', 'Taylor Reed']);
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_actions_per_user',
    '.report-actions-per-user',
    { width: 1100, height: 1000 }
  );
  await expectLabels(page.locator('.report-voting-record'), ['Votes issued', 'Votes missed', 'All votes cast']);
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_voting_record',
    '.report-voting-record',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_users_per_country', async ({ page, manual: screenshot }) => {
  await openReport(page);
  await expectLabels(page.locator('.report-users-per-country'), ['New Zealand', 'Australia']);
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_users_per_country',
    '.report-users-per-country',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_actions_per_country', async ({ page, manual: screenshot }) => {
  await openReport(page);
  await expectLabels(page.locator('.report-actions-per-country'), ['New Zealand', 'Australia', 'Canada']);
  await screenshot.captureElement(
    'groups/participation_report/group_participation_report_actions_per_country',
    '.report-actions-per-country',
    { width: 1100, height: 1000 }
  );
});

test('participation_report_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group');
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative');
  await page.locator('.group-page__actions .action-menu--btn').click();
  await expectLabel(page.locator('.v-overlay--active .action-dock__button--group_stats'), 'Participation report');
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
