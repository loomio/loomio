import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openDeleteGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-dock .action-menu--btn').click()
  await expect(page.locator('.v-overlay .action-dock__button--destroy_group').first()).toBeVisible()
  await expectLabel(page.locator('.v-overlay .action-dock__button--destroy_group'), 'Delete group')
}

test('delete_group_action', async ({ page, manual: screenshot }) => {
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

test('delete_group_confirmation', async ({ page, manual: screenshot }) => {
  await openDeleteGroup(page);
  await page.locator('.v-overlay .action-dock__button--destroy_group').click()
  await expect(page.locator('.confirm-modal').first()).toBeVisible()
  await expectLabel(page.locator('.confirm-modal'), "Type 'oatmilk-cooperative' to confirm")
  await page.locator('.confirm-text-field input').fill('oatmilk-cooperative')
  await expectLabel(page.locator('.confirm-modal__submit'), 'Delete group')
  await screenshot.captureElement('groups/deleting_your_group/group_delete_group_confirm', '.confirm-modal', {
    height: 1000
  });
});
