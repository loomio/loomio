require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')
notificationTexts = [
  'accepted your invitation to join',
  'added you to the group',
  'approved your request',
  'requested membership to',
  'mentioned you in',
  'replied to your comment',
  'shared an outcome',
  'Poll is closing soon',
  'started a Poll',
  'reacted to your comment',
  'made you a coordinator',
  'participated in',
  'added options to'
]

module.exports = {
  'has all the notifications': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_all_notifications')
    page.expectText('.notifications__activity', notificationTexts.length, 100000)
    page.click('.notifications__button')
    notificationTexts.map((text) => { page.expectText('.notifications__dropdown', text) })
  },

  'notifies inviter when invitation is accepted': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.members-card__invite-members-btn')
    page.fillIn('.invitation-form__email-addresses', 'max@example.com')
    page.click('.invitation-form__submit')
    page.pause()
    page.loadPath('accept_last_invitation')
    page.click('.notifications__button', 6000)
    page.expectText('.notifications__dropdown', 'Max Von Sydow accepted your invitation to join Dirty Dancing Shoes')
  }
}
