describe 'Dashboard Page', ->

  dashboardHelper = require './helpers/dashboard_helper.coffee'

  beforeEach ->
    dashboardHelper.load()

  it 'displays a view of recent threads', ->
    expect(dashboardHelper.proposalsThreads()).toContain('Starred proposal discussion')
    expect(dashboardHelper.proposalsThreads()).toContain('Proposal discussion')
    expect(dashboardHelper.proposalsThreads()).not.toContain('Starred discussion')

    expect(dashboardHelper.starredThreads()).toContain('Starred discussion')
    expect(dashboardHelper.starredThreads()).not.toContain('Starred proposal discussion')

    expect(dashboardHelper.todayThreads()).toContain('Recent discussion')

    expect(dashboardHelper.anyThreads()).not.toContain('Muted discussion')
    expect(dashboardHelper.anyThreads()).not.toContain('Old discussion')

  it 'displays a view of participating threads', ->
    dashboardHelper.openFilterDropdown()
    dashboardHelper.visitParticipatingView()
    expect(dashboardHelper.anyThreads()).not.toContain('Starred proposal discussion')
    expect(dashboardHelper.anyThreads()).not.toContain('Recent discussion')
    expect(dashboardHelper.anyThreads()).toContain('Participating discussion')

  xit 'displays a view of muted threads by group', ->
    dashboardHelper.openFilterDropdown()
    dashboardHelper.visitMutedView()
    browser.driver.sleep(10000)
    expect(dashboardHelper.firstGroupTitle()).toContain('Dirty Dancing Shoes')
    expect(dashboardHelper.anyThreads()).toContain('Muted discussion')
    expect(dashboardHelper.anyThreads()).not.toContain('Recent discussion')
