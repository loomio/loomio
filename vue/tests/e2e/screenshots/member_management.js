const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openMembers(page) {
  page.loadPath('setup_manual_oatmilk_group');
  page.expectText('.group-page__name', 'Oatmilk Cooperative');
  page.click('.group-page-members-tab');
  page.waitFor('.members-panel');
  page.expectText('.members-panel', 'Samira Patel');
}

function openMemberMenu(page, name = 'Samira Patel') {
  openMembers(page);
  page.execute(`Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('${name}') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()`);
  page.waitFor('.v-overlay .group-actions-dropdown__menu-content');
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

module.exports = {
  '@tags': ['manual-screenshot'],

  'member_actions': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMemberMenu(page);
    page.expectText('.v-overlay .group-actions-dropdown__menu-content', 'Remove from group');
    screenshot.capture('groups/member_management/member_management', {
      spotlight: menuSpotlight('.v-overlay .group-actions-dropdown__menu-content')
    });
  },

  'make_admin': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMemberMenu(page);
    page.expectText('.v-overlay .membership-dropdown__toggle-admin', 'Make admin');
    screenshot.capture('groups/member_management/member_make_admin', {
      spotlight: menuSpotlight('.v-overlay .membership-dropdown__toggle-admin')
    });
  },

  'join_closed_subgroup': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_closed_subgroup');
    page.expectText('.group-page__name', 'Packaging Working Group');
    page.expectText('.join-group-button', 'Join group');
    screenshot.capture('groups/member_management/member_join_subgroup', {
      spotlight: menuSpotlight('.join-group-button')
    });
  },

  'remove_member': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMemberMenu(page);
    page.expectText('.v-overlay .membership-dropdown__remove', 'Remove from group');
    screenshot.capture('groups/member_management/member_remove', {
      spotlight: menuSpotlight('.v-overlay .membership-dropdown__remove')
    });
  },

  'leave_group': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-dock .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--leave_group');
    screenshot.capture('groups/member_management/member_leave_group', {
      spotlight: menuSpotlight('.v-overlay .action-dock__button--leave_group')
    });
  },

  'set_title': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMemberMenu(page);
    page.expectText('.v-overlay .membership-dropdown__set-title', 'Set title');
    screenshot.capture('groups/member_management/member_set_title', {
      spotlight: menuSpotlight('.v-overlay .membership-dropdown__set-title')
    });
  }
};
