require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'displays unread threads by group': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_inbox', '.inbox-page__group')
    page.expectText('.inbox-page', 'Dirty Dancing Shoes')
    page.expectText('.inbox-page', 'Pinned discussion')
    page.expectElement('.thread-preview__pin')
    page.expectText('.inbox-page', 'Point Break')
    page.expectText('.inbox-page', 'Recent discussion')
    page.expectNoText('.inbox-page', 'Muted discussion')
    page.expectNoText('.inbox-page', 'Old discussion')
  }
}
