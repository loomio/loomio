
pageHelper = require('../helpers/pageHelper')

module.exports = {
  'invite_guest_to_vote': (test) => {
    page = pageHelper(test)
    page.loadPathNoApp('polls/test_invite_to_poll?guest=1')
    page.click('main h1 a')
    page.pause(1000)
    page.signUpViaInvitation()
    page.click('.poll-common-vote-form__button')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.expectElement('.action-dock__button--edit_stance')
  },

  'invite_member_to_vote': (test) => {
    page = pageHelper(test)
    page.loadPathNoApp('polls/test_invite_to_poll')
    page.click('main h1 a')
    page.pause(1000)
    page.signInViaPassword(null, 'password')
    page.click('.poll-common-vote-form__button')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.expectFlash('Vote created')
  }
}
