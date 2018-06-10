require('coffeescript/register')
pageHelper = require('../helpers/page_helper')

module.exports = {
  'successfully approves a membership request': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.membership-requests-card__link')
    page.click('.membership-requests-page__approve')
    page.pause(300)
    page.expectText('.membership-requests-page__previous-requests', 'Approved by Patrick Swayze')
  },

//   'adds_existing_users_to_group_upon_approval': (test) => {
//     page = pageHelper(test)

//     page.loadPath('setup_membership_requests')
//     page.pause(2000)
//     page.expectCount('.membership-card__membership', 4)
//     page.click('.membership-requests-card__link')
//     page.click('.membership-requests-page__approve')
//     page.ensureSidebar()
//     page.click('.sidebar__list-item-button--group')
//     page.pause()
//     page.expectCount('.membership-card__membership', 5)
//   },

  'displays the correct flash message': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.membership-requests-card__link')
    page.click('.membership-requests-page__approve')
    page.expectText('.flash-root__message', 'Membership request approved')
  },

  'successfully ignores a membership request': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.membership-requests-card__link')
    page.click('.membership-requests-page__ignore')
    page.expectText('.membership-requests-page__previous-requests', 'Ignored by Patrick Swayze')
  },

  'displays the correct flash message': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.membership-requests-card__link')
    page.click('.membership-requests-page__ignore')
    page.expectText('.flash-root__message', 'Membership request ignored')
  },

  'tells you there are no pending membership requests': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.membership-requests-card__link')
    page.click('.membership-requests-page__approve')
    page.pause(300)
    page.click('.membership-requests-page__approve')
    page.pause(300)
    page.click('.membership-requests-page__approve')
    page.pause(2000)
    page.expectText('.membership-requests-page__pending-requests', 'There are currently no pending membership requests for this group.')
  }
}
