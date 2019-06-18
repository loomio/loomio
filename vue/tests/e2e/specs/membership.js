require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'successfully_removes_a_group_member': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'Jennifer')
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__remove')
    // page.expectText('.confirm-modal p', 'Jennifer')
    page.expectText('.confirm-modal h1', 'Remove member')
    page.click('.confirm-modal__submit')
    page.expectFlash('Member removed')
    page.expectNoText('.members-panel', 'Jennifer Grey')
  },

  'successfully_assigns_coordinator_privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'Jennifer')
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectFlash('Jennifer Grey is now a coordinator')
  },

  'allows_non-coordinators_to_add_members_if_the_group_settings_allow': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.group-page-members-tab')
    page.expectElement('.membership-card__invite')
  },

  'can_remove_coordinator_privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')

    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'Emilio')
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectFlash('Emilio Estevez is no longer a coordinator')
  },

  'can_self_promote_when_no_coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_no_coordinators')
    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'Patrick')
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectFlash('Patrick Swayze is now a coordinator')
  },

  'can_self_promote_when_admin_of_parent_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups_as_admin')
    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'Jennifer')
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectFlash('Jennifer Grey is now a coordinator')
  },

  'cannot_self_promote_when_coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'Jennifer')
    page.click('.membership-dropdown__button')
    page.expectNoText('.membership-dropdown', 'Demote coordinator')
  },

  'can_set_membership_title': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'Patrick')
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__set-title')
    page.fillIn('.membership-form__title-input input', 'Suzerain')
    page.click('.membership-form__submit')
    page.expectFlash('Membership title updated')
    page.expectText('.members-panel__title', 'Suzerain')
    // page.expectText('.members-panel__table tbody', 'Patrick Swayze · Suzerain')
  }
}
