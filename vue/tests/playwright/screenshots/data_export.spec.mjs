import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('export_group_data_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-dock .action-menu--btn').click()
  await expect(page.locator('.v-overlay .action-dock__button--export_data').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay .action-dock__button--export_data'), 'Export group data')
  await screenshot.capture('groups/data_export/group_export_group_data', {
    spotlight: spotlight('.v-overlay .action-dock__button--export_data')
  });
});

test('print_thread_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expectLabel(page.locator('.topic-page'), 'Returnable bottles for cafe customers')
  await expect(page.locator('.topic-sidebar .action-dock__button--export_thread').first()).toBeVisible()
  await expectLabel(page.locator('.topic-sidebar .action-dock__button--export_thread'), 'Print')
  await screenshot.capture('groups/data_export/discussion_print_discussion', {
    spotlight: spotlight('.topic-sidebar .action-dock__button--export_thread')
  });
});
