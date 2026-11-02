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

async function openGroupSettings(page, scenario) {
  await page.loadPath(scenario);
  await page.expectText('.group-page__name', 'Packaging Working Group');
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--edit_group');
}

test('new_subgroup_action', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.ensureSidebar();
  await page.expectText('.sidebar-start-subgroup', 'New subgroup');
  await screenshot.capture('groups/subgroups/subgroups-sidebar', {
    spotlight: spotlight('.sidebar-start-subgroup')
  });
});

test('new_subgroup_form', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.ensureSidebar();
  await page.execute("Array.from(document.querySelectorAll('.sidebar-start-subgroup')).find(el => el.offsetParent).click()");
  await page.waitFor('.group-form');
  await page.fillIn('.group-form__name input', 'Packaging Working Group');
  await page.expectValue('.group-form__handle input', 'oatmilk-cooperative-packaging-working-group');
  await page.fillIn('.group-form__group-description [contenteditable=true]', 'Coordinate packaging suppliers, bottle returns, and labelling.');
  await page.click('.group-form__privacy-parent_members');
  await page.click('.group-form__membership-granted-upon-request label');
  await page.expectText('.group-form', 'Start subgroup');
  await screenshot.captureElement('groups/subgroups/subgroups_new', '.group-form', {height: 1200});
});

test('edit_subgroup_settings', async ({ lmo: page, manual: screenshot }) => {
  await openGroupSettings(page, 'setup_manual_oatmilk_subgroup_invitations');
  await screenshot.capture('groups/subgroups/subgroups_edit_group_settings', {
    spotlight: spotlight('.v-overlay .action-dock__button--edit_group')
  });
});

test('parent_members_private_threads', async ({ lmo: page, manual: screenshot }) => {
  await openGroupSettings(page, 'setup_manual_oatmilk_closed_subgroup_admin');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.click('.group-form__privacy-tab');
  await page.click('.group-form__privacy-parent_members');
  await page.click('.group-form__permissions-tab');
  await page.waitFor('.group-form__parent-members-can-see-discussions');
  await screenshot.captureElement('groups/subgroups/subgroups_private_threads_settings', '.group-form', {
    height: 1200,
    spotlight: spotlight('.group-form__parent-members-can-see-discussions')
  });
});

test('subgroup_privacy_settings', async ({ lmo: page, manual: screenshot }) => {
  await openGroupSettings(page, 'setup_manual_oatmilk_closed_subgroup_admin');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.click('.group-form__privacy-tab');
  await page.click('.group-form__privacy-parent_members');
  await page.click('.group-form__membership-granted-upon-request label');
  await page.expectChecked('.group-form__membership-granted-upon-request input');
  await page.expectText('.group-form__guide-link', 'Help');
  await page.expectText('.group-form__membership-granted-upon-request', 'Join without approval');
  await page.expectText('.group-form__membership-granted-upon-approval', 'Request to join');
  await page.expectText('.group-form__membership-granted-upon-invitation', 'Invitation only');
  await screenshot.captureElement('groups/subgroups/subgroups_privacy_settings', '.group-form', {
    height: 1200,
    spotlight: {
      selector: '.group-form__joining',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('find_subgroups', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_invitations');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.pause(500);
  await page.execute("Array.from(document.querySelectorAll('.sidebar__groups')).find(el => el.offsetParent).classList.add('manual-visible-groups')");
  await screenshot.capture('groups/subgroups/subgroups_find_subgroups', {
    spotlight: spotlight('.manual-visible-groups')
  });
});

test('invite_to_subgroups', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_subgroup_invitations');
  await page.expectText('.group-page__name', 'Packaging Working Group');
  await page.pause(500);
  await page.execute("Array.from(document.querySelectorAll('.sidebar__groups a')).find(el => el.offsetParent && el.textContent.includes('Oatmilk Cooperative')).click()");
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel');
  await page.click('.membership-card__invite');
  await page.waitFor('.group-invitation-form');
  await page.expectText('.group-invitation-form', 'Packaging Working Group');
  await page.execute("document.querySelectorAll('.invitation-form__select-groups input')[1].click()");
  await page.pause(200);
  await screenshot.captureElement('groups/subgroups/group_invite_email_subgroups', '.group-invitation-form', {height: 1000});
});

test('join_closed_subgroup', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_closed_subgroup');
  await page.expectText('.group-page__name', 'Packaging Working Group');
  await page.expectText('.join-group-button', 'Join group');
  await screenshot.capture('groups/subgroups/member_join_subgroup', {
    spotlight: spotlight('.join-group-button')
  });
});

test('become_subgroup_admin', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_closed_subgroup_member');
  await page.expectText('.group-page__name', 'Packaging Working Group');
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel');
  await page.execute("Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('Jamie Chen') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()");
  await page.waitFor('.v-overlay .membership-dropdown__toggle-admin');
  await page.expectText('.v-overlay .membership-dropdown__toggle-admin', 'Make admin');
  await screenshot.capture('groups/subgroups/member_make_admin', {
    spotlight: spotlight('.v-overlay .membership-dropdown__toggle-admin')
  });
});
