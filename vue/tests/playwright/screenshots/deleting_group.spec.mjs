import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

const deletionEnabled = /^[1-9][0-9]*$/.test(process.env.LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS || '');
const actionLabel = deletionEnabled ? 'Delete group' : 'Remove group';

async function openDeleteGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page__actions .action-menu--btn').click()
  await expectLabel(page.locator('.v-overlay--active .action-dock__button--destroy_group'), actionLabel)
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
  await page.locator('.v-overlay--active .action-dock__button--destroy_group').click()
  await expectLabel(page.locator('.confirm-modal'), "Type 'oatmilk-cooperative' to confirm")
  await page.locator('.confirm-text-field input').fill('oatmilk-cooperative')
  await expectLabel(page.locator('.confirm-modal__submit'), actionLabel)
  await screenshot.captureElement('groups/deleting_your_group/group_delete_group_confirm', '.confirm-modal', {
    height: 1000
  });
});
