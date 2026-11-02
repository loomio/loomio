import { test, expect } from '../screenshotFixtures.mjs';

async function openMembers(page) {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel');
  await page.expectText('.members-panel', 'Samira Patel');
}

async function openMemberMenu(page, name = 'Samira Patel') {
  await openMembers(page);
  await page.execute(`Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('${name}') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()`);
  await page.waitFor('.v-overlay .group-actions-dropdown__menu-content');
}

async function menuSpotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('member_actions', async ({ lmo: page, manual: screenshot }) => {
  await openMemberMenu(page);
  await page.expectText('.v-overlay .group-actions-dropdown__menu-content', 'Remove from group');
  await screenshot.capture('groups/member_management/member_management', {
    spotlight: menuSpotlight('.v-overlay .group-actions-dropdown__menu-content')
  });
});

test('make_admin', async ({ lmo: page, manual: screenshot }) => {
  await openMemberMenu(page);
  await page.expectText('.v-overlay .membership-dropdown__toggle-admin', 'Make admin');
  await screenshot.capture('groups/member_management/member_make_admin', {
    spotlight: menuSpotlight('.v-overlay .membership-dropdown__toggle-admin')
  });
});

test('join_closed_subgroup', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_closed_subgroup');
  await page.expectText('.group-page__name', 'Packaging Working Group');
  await page.expectText('.join-group-button', 'Join group');
  await screenshot.capture('groups/member_management/member_join_subgroup', {
    spotlight: menuSpotlight('.join-group-button')
  });
});

test('remove_member', async ({ lmo: page, manual: screenshot }) => {
  await openMemberMenu(page);
  await page.expectText('.v-overlay .membership-dropdown__remove', 'Remove from group');
  await screenshot.capture('groups/member_management/member_remove', {
    spotlight: menuSpotlight('.v-overlay .membership-dropdown__remove')
  });
});

test('leave_group', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page .action-dock .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--leave_group');
  await screenshot.capture('groups/member_management/member_leave_group', {
    spotlight: menuSpotlight('.v-overlay .action-dock__button--leave_group')
  });
});

test('set_title', async ({ lmo: page, manual: screenshot }) => {
  await openMemberMenu(page);
  await page.expectText('.v-overlay .membership-dropdown__set-title', 'Set title');
  await screenshot.capture('groups/member_management/member_set_title', {
    spotlight: menuSpotlight('.v-overlay .membership-dropdown__set-title')
  });
});
