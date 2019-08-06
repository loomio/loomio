require('coffeescript/register')
pageHelper = require('../helpers/page_helper')

module.exports = {
  'successfully removes a group member': (test) => {
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

  'successfully assigns admin privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Jennifer Grey is now an admin')
  },

  'allows non-admins to add members if the group settings allow': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.expectElement('.membership-card__invite')
  },

  'can remove admin privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')

    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Emilio')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Emilio Estevez is no longer an admin')
    page.expectNoElement('.user-avatar--admin')
  },

  'can_self_promote_when_no_admins': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_no_coordinators')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Patrick')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Patrick Swayze is now an admin')
  },

  'can_self_promote_when_admin_of_parent_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups_as_admin')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.click('.membership-dropdown__toggle-admin')
    page.expectText('.flash-root__message', 'Jennifer Grey is now an admin')
  },

  'cannot_self_promote_when_admins': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Jennifer')
    page.pause()
    page.click('.membership-dropdown__button')
    page.expectNoText('.membership-dropdown', 'Demote admin')
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
