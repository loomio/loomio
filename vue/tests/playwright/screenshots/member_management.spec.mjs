import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openMembers(page) {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page-members-tab').click()
  await expect(page.locator('.members-panel').first()).toBeVisible()
  await expectLabel(page.locator('.members-panel'), 'Samira Patel')
}

async function openMemberMenu(page, name = 'Samira Patel') {
  await openMembers(page);
  await page.evaluate(`Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('${name}') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()`)
  await expect(page.locator('.v-overlay .group-actions-dropdown__menu-content').first()).toBeVisible()
}

function menuSpotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('member_actions', async ({ page, manual: screenshot }) => {
  await openMemberMenu(page);
  await expectLabel(page.locator('.v-overlay .group-actions-dropdown__menu-content'), 'Remove from group')
  await screenshot.capture('groups/member_management/member_management', {
    spotlight: menuSpotlight('.v-overlay .group-actions-dropdown__menu-content')
  });
});

test('make_admin', async ({ page, manual: screenshot }) => {
  await openMemberMenu(page);
  await expectLabel(page.locator('.v-overlay .membership-dropdown__toggle-admin'), 'Make admin')
  await screenshot.capture('groups/member_management/member_make_admin', {
    spotlight: menuSpotlight('.v-overlay .membership-dropdown__toggle-admin')
  });
});

test('join_closed_subgroup', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_closed_subgroup')
  await expectLabel(page.locator('.group-page__name'), 'Packaging Working Group')
  await expectLabel(page.locator('.join-group-button'), 'Join group')
  await screenshot.capture('groups/member_management/member_join_subgroup', {
    spotlight: menuSpotlight('.join-group-button')
  });
});

test('remove_member', async ({ page, manual: screenshot }) => {
  await openMemberMenu(page);
  await expectLabel(page.locator('.v-overlay .membership-dropdown__remove'), 'Remove from group')
  await screenshot.capture('groups/member_management/member_remove', {
    spotlight: menuSpotlight('.v-overlay .membership-dropdown__remove')
  });
});

test('leave_group', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page .action-dock .action-menu--btn').click()
  await expect(page.locator('.v-overlay .action-dock__button--leave_group').first()).toBeVisible()
  await screenshot.capture('groups/member_management/member_leave_group', {
    spotlight: menuSpotlight('.v-overlay .action-dock__button--leave_group')
  });
});

test('set_title', async ({ page, manual: screenshot }) => {
  await openMemberMenu(page);
  await expectLabel(page.locator('.v-overlay .membership-dropdown__set-title'), 'Set title')
  await screenshot.capture('groups/member_management/member_set_title', {
    spotlight: menuSpotlight('.v-overlay .membership-dropdown__set-title')
  });
});
