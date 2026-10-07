const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'switching to a secret parent resets a public subgroup privacy selection': test => {
    const page = pageHelper(test);
    page.loadPath('setup_subgroup_privacy_parent_switching');
    page.ensureSidebar();
    page.click('.sidebar-start-subgroup');
    page.click('.group-form__privacy-open');
    test.assert.selected('.group-form__privacy-open input');
    page.click('.group-form__parent-group .v-field');
    page.waitFor('.v-overlay--active .v-select__content');
    page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Secret planning group')).click()");
    page.expectNoElement('.group-form__privacy-open');
    page.expectNoElement('.group-form__privacy-closed');
    test.assert.selected('.group-form__privacy-parent_members input');
    page.click('.group-form__membership-granted-upon-request');
    page.fillIn('#group-name', 'Internal work');
    page.expectValue('.group-form__handle input', 'secret-planning-internal-work');
    page.click('.group-form__submit-button');
    page.expectFlash('Group started');
  },

  'configure parent visibility and immediate joining when creating and editing a subgroup': test => {
    const page = pageHelper(test);
    page.loadPath('setup_closed_group');
    page.ensureSidebar();
    page.click('.sidebar-start-subgroup');
    page.fillIn('#group-name', 'Volunteer subgroup');
    page.click('.group-form__privacy-secret');
    page.expectNoElement('.group-form__membership-granted-upon-request');
    page.click('.group-form__privacy-parent_members');
    page.expectText('.group-form__membership-granted-upon-request', 'Members of Closed Dirty Dancing Shoes can join without approval');
    page.click('.group-form__membership-granted-upon-request');
    page.click('.group-form__submit-button');
    page.expectFlash('Group started');

    page.click('.action-menu');
    page.click('.action-dock__button--edit_group');
    page.click('.group-form__privacy-tab');
    test.assert.selected('.group-form__privacy-parent_members input');
    page.expectText('.group-form__membership-granted-upon-request', 'Members of Closed Dirty Dancing Shoes can join without approval');
    test.assert.selected('.group-form__membership-granted-upon-request input');
    page.click('.group-form__membership-granted-upon-approval');
    page.click('.group-form__submit-button');
    page.expectFlash('Group updated');

    page.click('.action-menu');
    page.click('.action-dock__button--edit_group');
    page.click('.group-form__privacy-tab');
    test.assert.selected('.group-form__membership-granted-upon-approval input');
    page.click('.group-form__membership-granted-upon-request');
    page.click('.group-form__permissions-tab');
    page.click('.group-form__parent-members-can-see-discussions');
    page.click('.group-form__submit-button');
    page.expectFlash('Group updated');

    page.click('.action-menu');
    page.click('.action-dock__button--edit_group');
    page.click('.group-form__privacy-tab');
    test.assert.selected('.group-form__privacy-parent_members input');
    test.assert.selected('.group-form__membership-granted-upon-request input');
    page.click('.group-form__permissions-tab');
    test.assert.selected('.group-form__parent-members-can-see-discussions input');
  },

  'a private parent offers parent visibility and secret subgroup privacy': test => {
    const page = pageHelper(test);
    page.loadPath('setup_secret_group');
    page.ensureSidebar();
    page.click('.sidebar-start-subgroup');
    page.fillIn('#group-name', 'Internal volunteers');
    page.expectValue('.group-form__handle input', 'secret-shoes-internal-volunteers');
    page.expectNoElement('.group-form__privacy-open');
    page.expectNoElement('.group-form__privacy-closed');
    page.click('.group-form__privacy-parent_members');
    page.click('.group-form__membership-granted-upon-request');
    page.click('.group-form__submit-button');
    page.expectFlash('Group started');
    page.click('.action-menu');
    page.click('.action-dock__button--edit_group');
    page.click('.group-form__privacy-tab');
    test.assert.selected('.group-form__privacy-parent_members input');
    page.expectNoElement('.group-form__privacy-open');
    page.expectNoElement('.group-form__privacy-closed');
  },

  'ordinary parent members can join leave and rejoin a parent visible subgroup': test => {
    const page = pageHelper(test);
    page.loadPath('setup_subgroup_parent_member_joining');
    page.click('.join-group-button');
    page.expectFlash('You are now a member');
    page.expectNoElement('.membership-request-form');
    page.click('.action-menu');
    page.expectNoElement('.action-dock__button--edit_group');
    page.click('.action-dock__button--leave_group');
    page.click('.confirm-modal__submit');
    page.expectFlash('You have left');
    test.back();
    page.waitFor('.join-group-button');
    page.click('.join-group-button');
    page.expectFlash('You are now a member');
  },

  'outsiders cannot self join through the subgroup page': test => {
    const page = pageHelper(test);
    page.loadPath('setup_subgroup_parent_member_joining_as_outsider');
    page.expectElement('.error-page__forbidden');
    page.expectNoElement('.join-group-button');
  },

  'outsiders can join a publicly visible subgroup with immediate joining': test => {
    const page = pageHelper(test);
    page.loadPath('setup_public_subgroup_immediate_joining_as_outsider');
    page.expectText('.group-page__name', 'Volunteer subgroup');
    page.click('.join-group-button');
    page.expectFlash('You are now a member');
  },

  'a pending approval request does not prevent an eligible parent member joining': test => {
    const page = pageHelper(test);
    page.loadPath('setup_subgroup_parent_member_joining_with_pending_request');
    page.click('.join-group-button');
    page.expectFlash('You are now a member');
  }
};
