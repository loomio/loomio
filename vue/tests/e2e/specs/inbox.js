require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'displays unread threads by group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_inbox')
    // TODO: GK: the inbox page component and the inbox service need a rework
    page.expectText('.inbox-page__group', 'Dirty Dancing Shoes')
    page.expectText('.inbox-page', 'Pinned discussion')
    page.expectText('.inbox-page', 'Point Break')
    page.expectText('.inbox-page', 'Recent discussion')
    page.expectNoText('.inbox-page', 'Muted discussion')
    page.expectNoText('.inbox-page', 'Old discussion')
  }
}
