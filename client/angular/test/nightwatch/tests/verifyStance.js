// require('coffeescript/register')
// _          = require('lodash')
// pageHelper = require('../helpers/page_helper.coffee')
//
// module.exports = {
//   'creates unverified stance then assigns it to verified user': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('polls/test_invitation_to_vote_in_poll', '.poll-mailer__poll-title')
//     page.click('.poll-mailer__poll-title', '.poll-common-participant-form__name')
//     page.fillIn('.poll-common-participant-form__name', 'Jimmy Unverified')
//     page.click('.poll-common-vote-form__option:first-child', '.poll-common-vote-form__submit')
//     page.click('.poll-common-vote-form__submit', '.flash-root__message')
//     page.expectText('.flash-root__message', 'Vote created')
//     page.waitFor('.verify-email-notice')
//     page.expectElement('.verify-email-notice')
//
//     page.loadPath('last_email', 'a')
//     page.click('a', '.sidebar__user-name')
//     page.expectText('.sidebar__user-name', 'Verified User')
//     page.click('.verify-stances-page__verify', '.auth-signin-form__submit')
//     page.click('.auth-signin-form__submit', '.flash-root__message')
//     page.expectText('.flash-root__message', 'Vote verified')
//   },
//
//   'creates unverified stance then verifies the user': (test) => {
//     page.loadPath('polls/test_invitation_to_vote_in_poll')
//     page.click('.poll-mailer__poll-title', '.poll-common-participant-form__name')
//     page.fillIn('.poll-common-participant-form__name', 'Jimmy New Person')
//     page.fillIn('.poll-common-participant-form__email', `${_.random(999999999)}@example.com`)
//     page.click('.poll-common-vote-form__option:first-child', '.poll-common-vote-form__submit')
//     page.click('.poll-common-vote-form__submit', '.flash-root__message')
//     page.expectElement('.flash-root__message', 'Vote created')
//     page.waitFor('.verify-email-notice')
//     page.expectElement('.verify-email-notice')
//
//     page.loadPath('last_email', 'a')
//     page.click('a', '.auth-signin-form__submit')
//     page.click('.auth-signin-form__submit', '.sidebar__user-name')
//     page.expectText('.sidebar__user-name', 'Jimmy New Person')
//     page.expectNoElement('.verify-email-notice')
//   }
// }
