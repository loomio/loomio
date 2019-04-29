require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'successfully_removes_a_group_member': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__remove')
    page.expectText('.confirm-modal p', 'Jennifer')
    page.click('.confirm-modal__submit')
    page.expectText('.flash-root__message', 'Member removed')
    page.expectNoText('.membership-card', 'Jennifer Grey')
  },

  'successfully assigns coordinator privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Jennifer Grey is now a coordinator')
  },

  'allows non-coordinators to add members if the group settings allow': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.expectElement('.membership-card__invite')
  },

  'can remove coordinator privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')

    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Emilio')
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
    page.fillIn('.membership-card__filter', 'Patrick')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Patrick Swayze is now a coordinator')
  },

  'can_self_promote_when_admin_of_parent_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups_as_admin')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Jennifer Grey is now a coordinator')
  },

  'cannot_self_promote_when_coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.expectNoText('.membership-dropdown', 'Demote coordinator')
  },

  'can_set_membership_title': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Patrick')
    page.pause()
    page.click('.membership-dropdown__button')
    page.pause()
    page.click('.membership-dropdown__set-title')
    page.fillIn('.membership-form__title-input', 'Suzerain')
    page.click('.membership-form__submit')
    page.expectText('.flash-root__message', 'Membership title updated')
    page.expectText('.membership-card', 'Patrick Swayze · Suzerain')
  }
}
