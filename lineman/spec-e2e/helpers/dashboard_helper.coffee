module.exports = new class DashboardHelper

  pageHeader: ->
    element.all(By.css('.lmo-h1-medium.dashboard-page__heading')).first()
