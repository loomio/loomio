page = require './helpers/page_helper.coffee'

describe 'Dashboard Page', ->

  beforeEach ->
    page.loadPath('setup_dashboard')

  it 'displays a view of recent threads', ->
    page.expectText('.dashboard-page__proposals','Starred proposal discussion')
    page.expectText('.dashboard-page__proposals','Proposal discussion')
    page.expectNoText('.dashboard-page__proposals', 'Starred discussion')

    page.expectText('.dashboard-page__starred', 'Starred discussion')
    page.expectNoText('.dashboard-page__starred', 'Starred proposal discussion')
    page.expectText('.dashboard-page__today', 'Recent discussion')

    page.expectNoText('.dashboard-page__collections', 'Muted discussion')
    page.expectNoText('.dashboard-page__collections', 'Muted group discussion')
    page.expectNoText('.dashboard-page__collections', 'Old discussion')

describe 'dismiss', ->
  xit 'dismisses a thread', ->
    page.loadPath 'setup_dashboard'
    threadPreview = page.findFirst('.thread-preview')
    browser.actions().mouseMove(threadPreview).perform()
    page.clickFirst '.thread-preview__dismiss'
    page.expectText '.dismiss-explanation-modal__title', 'Dismiss thread'
    page.click '.dismiss-explanation-modal__dismiss-thread'
    page.expectFlash 'Thread dismissed.'

describe 'muted threads', ->
  threadPreview = page.findFirst('.thread-preview')

  it 'explains muting if you have not yet muted a thread', ->
    page.loadPath 'setup_discussion'
    page.click '.sidebar__list-item-button--muted'
    page.expectText '.dashboard-page__explain-mute', "You haven't muted any threads yet"

  xit 'displays a mute explanation modal when you first mute a thread', ->
    page.loadPath 'setup_dashboard'
    browser.actions().mouseMove(threadPreview).perform()
    page.clickFirst '.thread-preview__mute'
    browser.driver.sleep(1000)
    page.expectText '.mute-explanation-modal__title', 'Mute thread'

  xit 'lets you mute a thread', ->
    page.loadPath 'setup_dashboard'
    browser.actions().mouseMove(threadPreview).perform()
    page.clickFirst '.thread-preview__mute'
    page.click '.mute-explanation-modal__mute-thread'
    browser.actions().mouseMove(threadPreview).perform()
    page.clickFirst '.thread-preview__mute'
    page.expectFlash 'Thread muted.'

describe 'Logged out', ->
  it 'forces visitors to log in', ->
    page.loadPath 'setup_dashboard_as_visitor'
    page.fillIn '#user-email', 'patrick_swayze@example.com'
    page.fillIn '#user-password', 'gh0stmovie'
    page.click '.sign-in-form__submit-button'
    page.waitForReload()
    page.expectText '.thread-previews-container', 'Recent discussion'
