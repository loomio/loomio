const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

function openGroupSettings(page, scenario) {
  page.loadPath(scenario);
  page.expectText('.group-page__name', 'Packaging Working Group');
  page.click('.group-page .action-menu--btn');
  page.waitFor('.v-overlay .action-dock__button--edit_group');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'new_subgroup_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.ensureSidebar();
    page.expectText('.sidebar-start-subgroup', 'New subgroup');
    screenshot.capture('groups/subgroups/subgroups-sidebar', {
      spotlight: spotlight('.sidebar-start-subgroup')
    });
  },

  'new_subgroup_form': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.ensureSidebar();
    page.execute("Array.from(document.querySelectorAll('.sidebar-start-subgroup')).find(el => el.offsetParent).click()");
    page.waitFor('.group-form');
    page.fillIn('.group-form__name input', 'Packaging Working Group');
    page.fillIn('.group-form__group-description [contenteditable=true]', 'Coordinate packaging suppliers, bottle returns, and labelling.');
    page.execute("document.querySelector('.group-form__privacy-closed input').click()");
    page.expectText('.group-form', 'Start subgroup');
    screenshot.captureElement('groups/subgroups/subgroups_new', '.group-form', {height: 1200});
  },

  'edit_subgroup_settings': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openGroupSettings(page, 'setup_manual_oatmilk_subgroup_invitations');
    screenshot.capture('groups/subgroups/subgroups_edit_group_settings', {
      spotlight: spotlight('.v-overlay .action-dock__button--edit_group')
    });
  },

  'parent_members_private_threads': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openGroupSettings(page, 'setup_manual_oatmilk_closed_subgroup_admin');
    page.click('.v-overlay .action-dock__button--edit_group');
    page.waitFor('.group-form');
    page.click('.group-form__permissions-tab');
    page.waitFor('.group-form__parent-members-can-see-discussions');
    screenshot.captureElement('groups/subgroups/subgroups_private_threads_settings', '.group-form', {
      height: 1200,
      spotlight: spotlight('.group-form__parent-members-can-see-discussions')
    });
  },

  'find_subgroups': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_invitations');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.pause(500);
    page.execute("Array.from(document.querySelectorAll('.sidebar__groups')).find(el => el.offsetParent).classList.add('manual-visible-groups')");
    screenshot.capture('groups/subgroups/subgroups_find_subgroups', {
      spotlight: spotlight('.manual-visible-groups')
    });
  },

  'invite_to_subgroups': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_subgroup_invitations');
    page.expectText('.group-page__name', 'Packaging Working Group');
    page.pause(500);
    page.execute("Array.from(document.querySelectorAll('.sidebar__groups a')).find(el => el.offsetParent && el.textContent.includes('Oatmilk Cooperative')).click()");
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page-members-tab');
    page.waitFor('.members-panel');
    page.click('.membership-card__invite');
    page.waitFor('.group-invitation-form');
    page.expectText('.group-invitation-form', 'Packaging Working Group');
    page.execute("document.querySelectorAll('.invitation-form__select-groups input')[1].click()");
    page.pause(200);
    screenshot.captureElement('groups/subgroups/group_invite_email_subgroups', '.group-invitation-form', {height: 1000});
  },

  'join_closed_subgroup': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_closed_subgroup');
    page.expectText('.group-page__name', 'Packaging Working Group');
    page.expectText('.join-group-button', 'Join group');
    screenshot.capture('groups/subgroups/member_join_subgroup', {
      spotlight: spotlight('.join-group-button')
    });
  },

  'become_subgroup_admin': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_closed_subgroup_member');
    page.expectText('.group-page__name', 'Packaging Working Group');
    page.click('.group-page-members-tab');
    page.waitFor('.members-panel');
    page.execute("Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('Jamie Chen') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()");
    page.waitFor('.v-overlay .membership-dropdown__toggle-admin');
    page.expectText('.v-overlay .membership-dropdown__toggle-admin', 'Make admin');
    screenshot.capture('groups/subgroups/member_make_admin', {
      spotlight: spotlight('.v-overlay .membership-dropdown__toggle-admin')
    });
  }
};
