import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { openSidebar, sidebarGroup } from '../helpers/groups.mjs';
import { member } from '../helpers/members.mjs';

function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

async function openGroupSettings(page, scenario) {
  await page.goto(`/dev/${scenario}`)
  await expectLabel(page.locator('.group-page__name'), 'Packaging Working Group')
  await page.locator('.group-page__actions .action-menu--btn').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--edit_group')).toBeVisible()
}

async function editPrivacy(page) {
  await openGroupSettings(page, 'setup_manual_oatmilk_closed_subgroup_admin');
  await page.locator('.v-overlay--active .action-dock__button--edit_group').click()
  await page.locator('.group-form__privacy-tab').click()
  await page.locator('.group-form__privacy-parent_members input').check()
}

test('new_subgroup_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.navbar__sidenav-toggle').click()
  await expectLabel(page.locator('.sidebar-start-subgroup'), 'New subgroup')
  await screenshot.capture('groups/subgroups/subgroups-sidebar', {
    spotlight: spotlight('.sidebar-start-subgroup')
  });
});

test('new_subgroup_form', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await openSidebar(page)
  await page.locator('.sidebar-start-subgroup').click()
  const form = page.locator('.group-form')
  await form.locator('.group-form__name input').fill('Packaging Working Group')
  await expect(form.locator('.group-form__handle input')).toHaveValue('oatmilk-cooperative-packaging-working-group')
  await editor(form.locator('.group-form__group-description')).fill('Coordinate packaging suppliers, bottle returns, and labelling.')
  await form.locator('.group-form__privacy-parent_members input').check()
  await form.locator('.group-form__membership-granted-upon-request input').check()
  await expectLabel(form, 'Start subgroup')
  await screenshot.captureElement('groups/subgroups/subgroups_new', '.group-form', {height: 1200});
});

test('edit_subgroup_settings', async ({ page, manual: screenshot }) => {
  await openGroupSettings(page, 'setup_manual_oatmilk_subgroup_invitations');
  await screenshot.capture('groups/subgroups/subgroups_edit_group_settings', {
    spotlight: spotlight('.v-overlay .action-dock__button--edit_group')
  });
});

test('parent_members_private_threads', async ({ page, manual: screenshot }) => {
  await editPrivacy(page);
  await page.locator('.group-form__permissions-tab').click()
  await expect(page.locator('.group-form__parent-members-can-see-discussions')).toBeVisible()
  await screenshot.captureElement('groups/subgroups/subgroups_private_threads_settings', '.group-form', {
    height: 1200,
    spotlight: spotlight('.group-form__parent-members-can-see-discussions')
  });
});

test('subgroup_privacy_settings', async ({ page, manual: screenshot }) => {
  await editPrivacy(page);
  await page.locator('.group-form__membership-granted-upon-request input').check()
  await expectLabel(page.locator('.group-form__guide-link'), 'Help')
  await expectLabel(page.locator('.group-form__membership-granted-upon-request'), 'Join without approval')
  await expectLabel(page.locator('.group-form__membership-granted-upon-approval'), 'Request to join')
  await expectLabel(page.locator('.group-form__membership-granted-upon-invitation'), 'Invitation only')
  await screenshot.captureElement('groups/subgroups/subgroups_privacy_settings', '.group-form', {
    height: 1200,
    spotlight: spotlight('.group-form__joining')
  });
});

test('find_subgroups', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_invitations')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  // The spotlight takes a CSS selector, which would match a hidden copy of
  // the group list too, so mark the one on screen.
  await page.locator('.sidebar__groups').filter({ visible: true }).evaluate(list => list.classList.add('manual-visible-groups'))
  await screenshot.capture('groups/subgroups/subgroups_find_subgroups', {
    spotlight: spotlight('.manual-visible-groups')
  });
});

test('invite_to_subgroups', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_subgroup_invitations')
  await expectLabel(page.locator('.group-page__name'), 'Packaging Working Group')
  await openSidebar(page)
  await sidebarGroup(page, 'Oatmilk Cooperative').click()
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.membership-card__invite').click()
  const form = page.locator('.group-invitation-form')
  await expectLabel(form, 'Packaging Working Group')
  // The second box is the first subgroup; the parent group comes first.
  await form.locator('.invitation-form__select-groups input').nth(1).click()
  await screenshot.captureElement('groups/subgroups/group_invite_email_subgroups', '.group-invitation-form', {height: 1000});
});

test('join_closed_subgroup', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_closed_subgroup')
  await expectLabel(page.locator('.group-page__name'), 'Packaging Working Group')
  await expectLabel(page.locator('.join-group-button'), 'Join group')
  await screenshot.capture('groups/subgroups/member_join_subgroup', {
    spotlight: spotlight('.join-group-button')
  });
});

test('become_subgroup_admin', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_closed_subgroup_member')
  await expectLabel(page.locator('.group-page__name'), 'Packaging Working Group')
  await page.locator('.group-page-members-tab').click()
  await member(page, 'Jamie Chen').locator('.membership-dropdown__button').click()
  await expectLabel(page.locator('.v-overlay--active .membership-dropdown__toggle-admin'), 'Make admin')
  await screenshot.capture('groups/subgroups/member_make_admin', {
    spotlight: spotlight('.v-overlay .membership-dropdown__toggle-admin')
  });
});
