require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'displays_unread_threads_by_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_inbox')
    page.expectText('.inbox-page__group', 'Dirty Dancing Shoes')
    page.expectText('.inbox-page', 'Pinned discussion')
    page.expectText('.inbox-page', 'Point Break')
    page.expectText('.inbox-page', 'Recent discussion')
    page.expectNoText('.inbox-page', 'Muted discussion')
    page.expectNoText('.inbox-page', 'Old discussion')
  }
}
