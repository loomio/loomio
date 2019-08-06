require('coffeescript/register')
pageHelper = require('../helpers/page_helper')
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
  'made you an admin',
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
  }
}
