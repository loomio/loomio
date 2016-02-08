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

  it 'displays a view of participating threads', ->
    page.click('.dashboard-page__filter-dropdown button')
    page.click('.dashboard-page__filter-participating a')
    page.expectNoText('.dashboard-page__collections','Starred proposal discussion')
    page.expectNoText('.dashboard-page__collections','Recent discussion')
    page.expectText('.dashboard-page__collections', 'Participating discussion')

  xit 'displays a view of muted threads by group', ->
    page.click('.dashboard-page__filter-dropdown button')
    page.click('.dashboard-page__filter-muted a')
    # browser.driver.sleep(10000)
    page.expectText('.dashboard-page__group-name', 'Dirty Dancing Shoes')
    page.expectText('.dashboard-page__collections', 'Muted discussion')
    page.expectText('.dashboard-page__collections', 'Muted group discussion')
    page.expectNoText('.dashboard-page__collections','Recent discussion')
