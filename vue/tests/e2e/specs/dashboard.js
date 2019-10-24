require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

// GK: muted threads still show up
// GK: what is the difference between muting and dismissing
// GK: is there still dimissing cus the option isn't there

module.exports = {
  'displays_a_view_of_recent_threads': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.expectText('.dashboard-page__collections', 'Poll discussion')
    page.expectText('.dashboard-page__collections', 'Recent discussion')
    // page.expectNoText('.dashboard-page__collections', 'Muted discussion')
    // page.expectNoText('.dashboard-page__collections', 'Muted group discussion')
    page.expectNoText('.dashboard-page__collections', 'Old discussion')
  },

  'dismisses_a_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_with_one_thread')
    page.expectElement('.thread-previews-container')
    // page.debug()
    page.click('.thread-preview .action-menu')
    page.click('.context-panel-dropdown__option--mute_thread')
    // page.mouseOver('.thread-preview', () => { page.click('.thread-preview__dismiss') })
    page.expectText('.confirm-modal h1', 'Mute thread')
    page.click('.confirm-modal__submit')
    page.expectFlash('Thread muted')
  },

  // 'explains_muting_if_you_have_not_yet_muted_a_thread': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_discussion')
  //   page.ensureSidebar()
  //   page.click('.sidebar__list-item-button--muted')
  //   page.expectText('.dashboard-page__explain-mute', "You haven't muted any threads yet")
  // },

  // 'lets you mute a thread': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_dashboard_with_one_thread')
  //   page.expectElement('.dashboard-page__collections')
  //   page.debug()
  //   page.mouseOver('.thread-preview', () => { page.click('.thread-preview__mute') })
  //   page.expectText('.confirm-modal h1', 'Mute thread')
  //   page.click('.confirm-modal__submit')
  //   page.expectFlash('Thread muted')
  // }
}
