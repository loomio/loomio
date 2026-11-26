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
  await page.locator('.group-cards__settings').click()
  await expectLabel(page.locator('.group-settings-panel .action-dock__button--export_data'), 'Export group data')
  await screenshot.captureElement('groups/data_export/group_export_group_data', '.group-page', {
    width: 1280,
    height: 2000,
    spotlight: spotlight('.group-settings-panel .action-dock__button--export_data')
  });
});

test('print_thread_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers')
  await expectLabel(page.locator('.topic-sidebar .action-dock__button--export_thread'), 'Print')
  await screenshot.capture('groups/data_export/discussion_print_discussion', {
    spotlight: spotlight('.topic-sidebar .action-dock__button--export_thread')
  });
});
