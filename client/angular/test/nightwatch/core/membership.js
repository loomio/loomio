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

  'can remove coordinator privileges when there is more than one coordinator': (test) => {
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

  'cannot_remove_privileges_for_last_coordinator': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.membership-card__search-button')
    page.fillIn('.membership-card__filter', 'Patrick')
    page.pause()
    page.click('.membership-dropdown__button')
    page.pause()
    page.expectNoText('.membership-dropdown', 'Demote coordinator')
  }
}
