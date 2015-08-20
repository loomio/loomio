module.exports = new class DashboardHelper

  load: ->
    browser.get('http://localhost:8000/development/setup_dashboard')

  pageHeader: ->
    element.all(By.css('.lmo-h1-medium.dashboard-page__heading')).first()

  openFilterDropdown: ->
    element(By.css('.dashboard-page__filter-dropdown button')).click()

  visitParticipatingView: ->
    element(By.css('.dashboard-page__filter-participating a')).click()

  visitMutedView: ->
    element(By.css('.dashboard-page__filter-muted a')).click()

  proposalsThreads: ->
    element(By.css('.dashboard-page__proposals')).getText()

  starredThreads: ->
    element(By.css('.dashboard-page__starred')).getText()

  todayThreads: ->
    element(By.css('.dashboard-page__today')).getText()

  yesterdayThreads: ->
    element(By.css('.dashboard-page__yesterday')).getText()

  anyThreads: ->
    element(By.css('.dashboard-page__collections')).getText()

  firstGroupTitle: ->
    element.all(By.css('.dashboard-page__group-name')).first().getText()
