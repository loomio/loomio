require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'displays_a_view_of_recent_threads': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.expectText('.dashboard-page__collections', 'Poll discussion')
    page.expectText('.dashboard-page__collections', 'Recent discussion')
    page.expectNoText('.dashboard-page__collections', 'Old discussion')
  },

  'dismisses_a_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_with_one_thread')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--recent')
    page.expectElement('.thread-previews-container')
    page.click('.thread-preview .action-menu')
    page.click('.action-dock__button--dismiss_thread')
    page.expectText('.confirm-modal h1', 'Dismiss thread')
    page.click('.confirm-modal__submit')
    page.expectFlash('Thread marked as read')
  },

}
