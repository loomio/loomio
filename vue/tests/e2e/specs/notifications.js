require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

notificationTexts = [
  'accepted your invitation to join',
  'added you to the group',
  'approved your request',
  'requested membership to',
  'mentioned you in',
  'replied to your comment',
  'shared an outcome',
  'poll is closing soon',
  'shared a poll',
  'reacted 🙂 to your comment',
  'made you an admin',
  'participated in',
  'added options to'
]

module.exports = {
  'has_all_the_notifications': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_all_notifications')
    page.pause(500)
    page.expectText('.notifications__activity', notificationTexts.length, 100000)
    page.click('.notifications__button')
    notificationTexts.map((text) => { page.expectText('.notifications__dropdown', text) })
  }
}
