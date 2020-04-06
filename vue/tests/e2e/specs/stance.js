require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'invite_guest_to_vote': (test) => {
    page = pageHelper(test)
    page.loadPathNoApp('polls/test_invite_to_poll?guest=1')
    page.click('.poll-mailer__poll-title', 2000)
    page.signUpViaInvitation()
    page.click('.poll-common-vote-form__button')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.waitForElementNotVisible('.submit-overlay')
    page.expectElement('.action-dock__button--edit_stance')
  },

  'invite_member_to_vote': (test) => {
    page = pageHelper(test)
    page.loadPathNoApp('polls/test_invite_to_poll')
    page.click('.poll-mailer__poll-title', 2000)
    page.signInViaPassword(null, 'loginlogin')
    page.click('.poll-common-vote-form__button')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.expectFlash('Vote created')
  }
}
