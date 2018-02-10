require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'displays a view of recent threads': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.expectText('.dashboard-page__collections', 'Poll discussion')
    page.expectText('.dashboard-page__collections', 'Recent discussion')
    page.expectNoText('.dashboard-page__collections', 'Muted discussion')
    page.expectNoText('.dashboard-page__collections', 'Muted group discussion')
    page.expectNoText('.dashboard-page__collections', 'Old discussion')
  },

  'dismisses a thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.mouseOver('.thread-preview')
    page.click('.thread-preview__dismiss')
    page.expectText('.dismiss-explanation-modal h1', 'Dismiss thread')
    page.click('.dismiss-explanation-model__submit')
    page.expectText('.flash-root__message', 'Thread dismissed')
  },

  'explains muting if you have not yet muted a thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.sidebar__list-item-button--muted')
    page.expectText('.dashboard-page__explain-mute', "You haven't muted any threads yet")
  },

  'lets you mute a thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.mouseOver('.thread-preview')
    page.click('.thread-preview__mute')
    page.expectText('.mute-explanation-modal__title', 'Mute thread')
    page.click('.mute-explanation-modal__mute-thread')
    page.mouseOver('.thread-preview')
    page.click('.thread-preview__mute')
    page.expectText('.flash-root__message', 'Thread muted')
  }
}
