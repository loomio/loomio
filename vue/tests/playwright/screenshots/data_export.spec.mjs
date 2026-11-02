import { test, expect } from '../screenshotFixtures.mjs';

async function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('export_group_data_action', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-dock .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--export_data');
  await page.expectText('.v-overlay .action-dock__button--export_data', 'Export group data');
  await screenshot.capture('groups/data_export/group_export_group_data', {
    spotlight: spotlight('.v-overlay .action-dock__button--export_data')
  });
});

test('print_thread_action', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-page');
  await page.expectText('.topic-page', 'Returnable bottles for cafe customers');
  await page.waitFor('.topic-sidebar .action-dock__button--export_thread');
  await page.expectText('.topic-sidebar .action-dock__button--export_thread', 'Print');
  await screenshot.capture('groups/data_export/discussion_print_discussion', {
    spotlight: spotlight('.topic-sidebar .action-dock__button--export_thread')
  });
});
