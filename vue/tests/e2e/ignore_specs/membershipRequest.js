require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'successfully_approves_a_membership_request': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.group-page-members-tab')
    page.click('.group-page__requests-tab')
    page.click('.membership-requests-page__approve', 500)
    page.expectFlash('Membership request approved')
    page.expectText('.membership-request__response', 'Approved by Patrick Swayze')
  },

  'adds_existing_users_to_group_upon_approval': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.group-page-members-tab')
    page.expectCount('.members-panel .v-list .v-list-item', 3)
    page.click('.group-page__requests-tab')
    page.click('.membership-requests-page__approve', 500)
    page.expectFlash('Membership request approved')
    page.click('.group-page-members-tab')
    page.expectCount('.members-panel .v-list .v-list-item', 4)
  },


  'successfully_ignores_a_membership_request': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.group-page-members-tab')
    page.click('.group-page__requests-tab')
    page.click('.membership-requests-page__ignore', 500)
    page.expectFlash('Membership request ignored')
    page.expectText('.membership-request__response', 'Ignored by Patrick Swayze')
  },
}
