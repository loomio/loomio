require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'successfully_removes_a_group_member': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter input', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__remove')
    // page.expectText('.confirm-modal p', 'Jennifer')
    page.expectText('.confirm-modal h1', 'Remove member')
    page.click('.confirm-modal__submit')
    page.expectText('.flash-root__message', 'Member removed')
    page.expectNoText('.membership-card', 'Jennifer Grey')
  },

  'successfully_assigns_coordinator_privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter input', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Jennifer Grey is now a coordinator')
  },

  'allows_non-coordinators_to_add_members_if_the_group_settings_allow': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.expectElement('.membership-card__invite')
  },

  'can_remove_coordinator_privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')

    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter input', 'Emilio')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Emilio Estevez is no longer a coordinator')
    page.expectNoElement('.user-avatar--coordinator')
  },

  'can_self_promote_when_no_coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_no_coordinators')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter input', 'Patrick')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Patrick Swayze is now a coordinator')
  },

  'can_self_promote_when_admin_of_parent_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups_as_admin')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter input', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Jennifer Grey is now a coordinator')
  },

  'cannot_self_promote_when_coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter input', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.expectNoText('.membership-dropdown', 'Demote coordinator')
  },

  'can_set_membership_title': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter input', 'Patrick')
    page.pause()
    page.click('.membership-dropdown__button')
    page.pause()
    page.click('.membership-dropdown__set-title')
    page.fillIn('.membership-form__title-input input', 'Suzerain')
    page.click('.membership-form__submit')
    page.expectText('.flash-root__message', 'Membership title updated')
    page.expectText('.membership-card', 'Patrick Swayze · Suzerain')
  }
}
