require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'successfully approves a membership request': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.membership-requests-card__link')
    page.click('.membership-requests-page__approve')
    page.pause(300)
    page.expectText('.membership-requests-page__previous-requests', 'Approved by Patrick Swayze')
  },

  'adds existing users to group upon approval': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.membership-requests-card__link')
    page.click('.membership-requests-page__approve')
    page.click('.membership-requests-page__approve')
    page.click('.sidebar__list-item-button--group')
    page.expectText('.members-card', 'MVS')
  },

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
    page.pause(300)
    page.click('.membership-requests-page__approve')
    page.pause(2000)
    page.expectText('.membership-requests-page__pending-requests', 'There are currently no pending membership requests for this group.')
  }
}
