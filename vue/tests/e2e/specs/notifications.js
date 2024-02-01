pageHelper = require('../helpers/pageHelper')

module.exports = {
  'has_all_the_notifications': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_all_notifications')
    page.pause(500)
    page.click('.notifications__button')
    page.expectText('.notifications__dropdown', 'accepted your invitation to join')
    page.expectText('.notifications__dropdown', 'invited you to join')
    page.expectText('.notifications__dropdown', 'approved your request')
    page.expectText('.notifications__dropdown', 'requested to join')
    page.expectText('.notifications__dropdown', 'mentioned you in')
    page.expectText('.notifications__dropdown', 'replied to you in' )
    page.expectText('.notifications__dropdown', 'shared a poll outcome')
    page.expectText('.notifications__dropdown', 'poll closing in 24 hours')
    page.expectText('.notifications__dropdown', 'shared a poll')
    page.expectText('.notifications__dropdown', 'reacted 🙂 to your comment')
    page.expectText('.notifications__dropdown', 'made you an admin')
  }
}
