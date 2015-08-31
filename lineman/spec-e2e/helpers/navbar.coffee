module.exports = new class Navbar
  clickRecent: ->
    element(By.css('.lmo-navbar__recent')).click()

  enterSearchQuery: (query) ->
    element(By.css('.navbar-search-input')).sendKeys(query)

  clickFirstSearchResult: ->
    element(By.css('.navbar-search-results a.selector-list-item-link')).click()

