import { test, expect } from '../screenshotFixtures.mjs';

async function openDeleteGroup(page) {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-dock .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--destroy_group');
  await page.expectText('.v-overlay .action-dock__button--destroy_group', 'Delete group');
}

test('delete_group_action', async ({ lmo: page, manual: screenshot }) => {
  await openDeleteGroup(page);
  await screenshot.capture('groups/deleting_your_group/group_delete_group', {
    spotlight: {
      selector: '.v-overlay .action-dock__button--destroy_group',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('delete_group_confirmation', async ({ lmo: page, manual: screenshot }) => {
  await openDeleteGroup(page);
  await page.click('.v-overlay .action-dock__button--destroy_group');
  await page.waitFor('.confirm-modal');
  await page.expectText('.confirm-modal', "Type 'oatmilk-cooperative' to confirm");
  await page.fillIn('.confirm-text-field input', 'oatmilk-cooperative');
  await page.expectText('.confirm-modal__submit', 'Delete group');
  await screenshot.captureElement('groups/deleting_your_group/group_delete_group_confirm', '.confirm-modal', {
    height: 1000
  });
});
