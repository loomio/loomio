module.exports = new class DashboardHelper

  flashSection: ->
    element(By.css('.flash-message'))

  pageHeader: ->
    element.all(By.css('.lmo-h1-medium.dashboard-page__heading')).first()
