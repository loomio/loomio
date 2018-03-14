require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'successfully removes a group member': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.members-card__manage-members')
    page.fillIn('.membership-page__search-filter', 'Jennifer')
    page.pause()
    page.click('.memberships-panel__remove')
    page.click('.memberships-page__remove-membership-confirm')
    page.expectNoElement('.memberships-page__membership')
    page.fillIn('.membership-page__search-filter', '')
    page.expectText('.flash-root__message', 'Removed Jennifer Grey')
    page.expectNoText('.memberships-panel', 'Jennifer Grey')
  },

  'successfully assigns coordinator privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.members-card__manage-members')
    page.fillIn('.membership-page__search-filter', 'Jennifer')
    page.pause()
    page.click('.memberships-panel__toggle-coordinator')
    page.fillIn('.membership-page__search-filter', '')
    page.pause()
    page.expectText('.flash-root__message', 'Jennifer Grey is now a coordinator')
    page.expectCount('.user-avatar--coordinator', 2)
  },

  'allows non-coordinators to add members if the group settings allow': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.members-card__manage-members')
    page.expectElement('.memberships-panel__membership')
    page.expectElement('.memberships-page__invite')
  },

  'can remove coordinator privileges when there is more than one coordinator': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.members-card__manage-members')
    page.fillIn('.membership-page__search-filter', 'Jennifer')
    page.pause()
    page.click('.memberships-panel__toggle-coordinator')
    page.fillIn('.membership-page__search-filter', '')
    page.pause()
    page.expectCount('.user-avatar--coordinator', 2)
    page.fillIn('.membership-page__search-filter', 'Patrick')
    page.pause()
    page.click('.memberships-panel__toggle-coordinator')
    page.expectText('.flash-root__message', 'Patrick Swayze is no longer a coordinator')
    page.fillIn('.membership-page__search-filter', '')
    page.pause()
    page.expectCount('.user-avatar--coordinator', 1)
  },

  'cannot remove privileges for last coordinator': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.members-card__manage-members')
    page.expectCount('.user-avatar--coordinator', 1)
    page.fillIn('.membership-page__search-filter', 'Patrick')
    page.expectElement('.memberships-panel__toggle-coordinator[disabled]')
  }
}
