page = require './helpers/page_helper.coffee'

describe 'Dashboard Page', ->
  threadPreview = page.findFirst('.thread-preview')

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

  it 'displays a view of participating threads', ->
    page.click('.dashboard-page__filter-dropdown button')
    page.click('.dashboard-page__filter-participating a')
    page.expectNoText('.dashboard-page__collections','Starred proposal discussion')
    page.expectNoText('.dashboard-page__collections','Recent discussion')
    page.expectText('.dashboard-page__collections', 'Participating discussion')

  it 'displays a mute explanation modal when you first mute', ->
    browser.actions().mouseMove(threadPreview).perform()
    page.clickFirst('.thread-preview__mute')
    browser.driver.sleep(1000)
    page.expectText('.mute-explanation-modal__title', 'Mute thread')

  it 'lets you mute a thread', ->
    browser.actions().mouseMove(threadPreview).perform()
    page.clickFirst('.thread-preview__mute')
    page.click('.mute-explanation-modal__mute-thread')
    browser.actions().mouseMove(threadPreview).perform()
    page.clickFirst('.thread-preview__mute')
    page.expectFlash('Thread muted.')

describe 'Logged out', ->
  it 'forces visitors to log in', ->
    page.loadPath 'setup_dashboard_as_visitor'
    page.fillIn '#user-email', 'patrick_swayze@example.com'
    page.fillIn '#user-password', 'gh0stmovie'
    page.click '.sign-in-form__submit-button'
    page.expectText '.thread-previews-container', 'Recent discussion'
