// require('coffeescript/register')
// pageHelper = require('../helpers/pageHelper.coffee')
//
//
// module.exports = {
//   'displays a view of recent threads': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_dashboard')
//     page.expectText('.dashboard-page__collections', 'Poll discussion')
//     page.expectText('.dashboard-page__collections', 'Recent discussion')
//     page.expectNoText('.dashboard-page__collections', 'Muted discussion')
//     page.expectNoText('.dashboard-page__collections', 'Muted group discussion')
//     page.expectNoText('.dashboard-page__collections', 'Old discussion')
//   },
//
//   'dismisses_a_thread': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_dashboard_with_one_thread')
//     page.expectElement('.thread-previews-container')
//     page.mouseOver('.thread-preview', () => { page.click('.thread-preview__dismiss') })
//     page.expectText('.confirm-modal h1', 'Dismiss thread')
//     page.click('.confirm-modal__submit')
//     page.expectFlash('Thread dismissed')
//   },
//
//   // 'explains_muting_if_you_have_not_yet_muted_a_thread': (test) => {
//   //   page = pageHelper(test)
//   //
//   //   page.loadPath('setup_discussion')
//   //   page.ensureSidebar()
//   //   page.click('.sidebar__list-item-button--muted')
//   //   page.expectText('.dashboard-page__explain-mute', "You haven't muted any threads yet")
//   // },
//
//   'lets you mute a thread': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_dashboard_with_one_thread')
//     page.expectElement('.dashboard-page__collections')
//     page.mouseOver('.thread-preview', () => { page.click('.thread-preview__mute') })
//     page.expectText('.confirm-modal h1', 'Mute thread')
//     page.click('.confirm-modal__submit')
//     page.expectFlash('Thread muted')
//   }
// }
