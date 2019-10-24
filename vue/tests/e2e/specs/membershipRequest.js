// require('coffeescript/register')
// pageHelper = require('../helpers/pageHelper.coffee')
//
// module.exports = {
//   'successfully_approves_a_membership_request': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_membership_requests')
//     page.click('.group-page-members-tab')
//     page.click('.membership-requests-link')
//     page.click('.membership-requests-page__approve', 500)
//     page.expectText('.membership-requests-page__previous-requests', 'Approved by Patrick Swayze')
//   },
//
//   'adds_existing_users_to_group_upon_approval': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_membership_requests')
//     page.click('.group-page-members-tab', 500)
//     page.expectCount('.members-panel__name', 3)
//     page.click('.membership-requests-link')
//     page.click('.membership-requests-page__approve')
//     page.ensureSidebar()
//
//     page.click('.sidebar__groups', 500)
//     page.click('.group-page-members-tab')
//     page.expectCount('.members-panel__name', 4)
//   },
//
//   'displays_the_correct_flash_message_for_approval': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_membership_requests')
//     page.click('.group-page-members-tab')
//     page.click('.membership-requests-link')
//     page.click('.membership-requests-page__approve')
//     page.expectFlash('Membership request approved')
//   },
//
//   'successfully_ignores_a_membership_request': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_membership_requests')
//     page.click('.group-page-members-tab')
//     page.click('.membership-requests-link')
//     page.click('.membership-requests-page__ignore')
//     page.expectText('.membership-requests-page__previous-requests', 'Ignored by Patrick Swayze')
//   },
//
//   'displays_the_correct_flash_message_for_ignoring': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_membership_requests')
//     page.click('.group-page-members-tab')
//     page.click('.membership-requests-link')
//     page.click('.membership-requests-page__ignore')
//     page.expectFlash('Membership request ignored')
//   },
//
//   'tells_you_there_are_no_pending_membership_requests': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_membership_requests')
//     page.click('.group-page-members-tab')
//     page.click('.membership-requests-link')
//     page.click('.membership-requests-page__approve', 500)
//     page.click('.membership-requests-page__approve', 500)
//     page.click('.membership-requests-page__approve', 500)
//     page.expectText('.membership-requests-page__pending-requests', 'There are currently no pending membership requests for this group.')
//   }
// }
