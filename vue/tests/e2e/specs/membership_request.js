pageHelper = require('../helpers/pageHelper')

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

  // 'adds_existing_users_to_group_upon_approval': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_membership_requests')
  //   page.click('.group-page-members-tab')
  //   page.expectCount('.members-panel .v-list .v-list-item', 3)
  //   page.click('.group-page__requests-tab')
  //   page.click('.membership-requests-page__approve', 500)
  //   page.expectFlash('Membership request approved')
  //   page.click('.group-page-members-tab')
  //   page.expectCount('.members-panel .v-list .v-list-item', 4)
  // },


  'successfully_declines_a_membership_request': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.group-page-members-tab')
    page.click('.group-page__requests-tab')
    page.click('.membership-requests-page__decline', 500)
    page.expectText('.membership-request__decline-help', 'Decline sends your reason to the applicant by email. They can submit a new request. Ignore closes the request without notifying them.')
    page.fillIn('.membership-request__response-comment-input textarea', 'Please answer the join prompt')
    page.click('.membership-request__response-submit', 500)
    page.expectFlash('Membership request declined')
    page.expectText('.membership-request__response', 'Declined by Patrick Swayze')
    page.expectText('.membership-request__response-comment', 'Please answer the join prompt')
  },

  'successfully_ignores_a_membership_request': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_membership_requests')
    page.click('.group-page-members-tab')
    page.click('.group-page__requests-tab')
    page.click('.membership-requests-page__decline', 500)
    page.click('.membership-request__ignore', 500)
    page.expectFlash('Membership request ignored')
    page.expectText('.membership-request__response', 'Ignored by Patrick Swayze')
  },
}
