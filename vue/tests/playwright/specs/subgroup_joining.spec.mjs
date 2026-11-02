import { test, expect } from '../fixtures.mjs';

test('switching to a secret parent resets a public subgroup privacy selection', async ({ lmo: page }) => {
  await page.loadPath('setup_subgroup_privacy_parent_switching');
  await page.ensureSidebar();
  await page.click('.sidebar-start-subgroup');
  await page.click('.group-form__privacy-open');
  await page.expectChecked('.group-form__privacy-open input');
  await page.click('.group-form__parent-group .v-field');
  await page.waitFor('.v-overlay--active .v-select__content');
  await page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Secret planning group')).click()");
  await page.expectNoElement('.group-form__privacy-open');
  await page.expectNoElement('.group-form__privacy-closed');
  await page.expectChecked('.group-form__privacy-parent_members input');
  await page.click('.group-form__membership-granted-upon-request label');
  await page.fillIn('#group-name', 'Internal work');
  await page.expectValue('.group-form__handle input', 'secret-planning-internal-work');
  await page.click('.group-form__submit-button');
  await page.expectFlash('Group started');
});

test('configure parent visibility and immediate joining when creating and editing a subgroup', async ({ lmo: page }) => {
  await page.loadPath('setup_closed_group');
  await page.ensureSidebar();
  await page.click('.sidebar-start-subgroup');
  await page.fillIn('#group-name', 'Volunteer subgroup');
  await page.click('.group-form__privacy-secret');
  await page.expectNoElement('.group-form__membership-granted-upon-request');
  await page.click('.group-form__privacy-parent_members');
  await page.expectText('.group-form__membership-granted-upon-request', 'Join without approval');
  await page.click('.group-form__membership-granted-upon-request label');
  await page.expectChecked('.group-form__membership-granted-upon-request input');
  await page.click('.group-form__submit-button');
  await page.expectFlash('Group started');

  await page.click('.action-menu');
  await page.click('.action-dock__button--edit_group');
  await page.expectText('.group-form__guide-link', 'Help');
  await page.expectAttribute('.group-form__guide-link', 'href', '/user_manual/groups/settings/profile');
  await page.click('.group-form__privacy-tab');
  await page.expectText('.group-form__guide-link', 'Help');
  await page.expectAttribute('.group-form__guide-link', 'href', '/user_manual/groups/settings/privacy');
  await page.expectChecked('.group-form__privacy-parent_members input');
  await page.expectText('.group-form__membership-granted-upon-request', 'Join without approval');
  await page.expectChecked('.group-form__membership-granted-upon-request input');
  await page.click('.group-form__membership-granted-upon-approval label');
  await page.click('.group-form__submit-button');
  await page.expectFlash('Group updated');

  await page.click('.action-menu');
  await page.click('.action-dock__button--edit_group');
  await page.click('.group-form__privacy-tab');
  await page.expectChecked('.group-form__membership-granted-upon-approval input');
  await page.click('.group-form__membership-granted-upon-request label');
  await page.click('.group-form__permissions-tab');
  await page.expectText('.group-form__guide-link', 'Help');
  await page.expectAttribute('.group-form__guide-link', 'href', '/user_manual/groups/settings/permissions');
  await page.click('.group-form__parent-members-can-see-discussions');
  await page.click('.group-form__submit-button');
  await page.expectFlash('Group updated');

  await page.click('.action-menu');
  await page.click('.action-dock__button--edit_group');
  await page.click('.group-form__privacy-tab');
  await page.expectChecked('.group-form__privacy-parent_members input');
  await page.expectChecked('.group-form__membership-granted-upon-request input');
  await page.click('.group-form__permissions-tab');
  await page.expectChecked('.group-form__parent-members-can-see-discussions input');
});

test('a private parent offers parent visibility and secret subgroup privacy', async ({ lmo: page }) => {
  await page.loadPath('setup_secret_group');
  await page.ensureSidebar();
  await page.click('.sidebar-start-subgroup');
  await page.fillIn('#group-name', 'Internal volunteers');
  await page.expectValue('.group-form__handle input', 'secret-shoes-internal-volunteers');
  await page.expectNoElement('.group-form__privacy-open');
  await page.expectNoElement('.group-form__privacy-closed');
  await page.click('.group-form__privacy-parent_members');
  await page.click('.group-form__membership-granted-upon-request label');
  await page.click('.group-form__submit-button');
  await page.expectFlash('Group started');
  await page.click('.action-menu');
  await page.click('.action-dock__button--edit_group');
  await page.click('.group-form__privacy-tab');
  await page.expectChecked('.group-form__privacy-parent_members input');
  await page.expectNoElement('.group-form__privacy-open');
  await page.expectNoElement('.group-form__privacy-closed');
});

test('ordinary parent members can join leave and rejoin a parent visible subgroup', async ({ lmo: page }) => {
  await page.loadPath('setup_subgroup_parent_member_joining');
  await page.click('.join-group-button');
  await page.expectFlash('You are now a member');
  await page.expectNoElement('.membership-request-form');
  await page.click('.action-menu');
  await page.expectNoElement('.action-dock__button--edit_group');
  await page.click('.action-dock__button--leave_group');
  await page.click('.confirm-modal__submit');
  await page.expectFlash('You have left');
  await page.page.goBack();
  await page.waitFor('.join-group-button');
  await page.click('.join-group-button');
  await page.expectFlash('You are now a member');
});

test('outsiders cannot self join through the subgroup page', async ({ lmo: page }) => {
  await page.loadPath('setup_subgroup_parent_member_joining_as_outsider');
  await page.expectElement('.error-page__forbidden');
  await page.expectNoElement('.join-group-button');
});

test('outsiders can join a publicly visible subgroup with immediate joining', async ({ lmo: page }) => {
  await page.loadPath('setup_public_subgroup_immediate_joining_as_outsider');
  await page.expectText('.group-page__name', 'Volunteer subgroup');
  await page.click('.join-group-button');
  await page.expectFlash('You are now a member');
});

test('a pending approval request does not prevent an eligible parent member joining', async ({ lmo: page }) => {
  await page.loadPath('setup_subgroup_parent_member_joining_with_pending_request');
  await page.click('.join-group-button');
  await page.expectFlash('You are now a member');
});
