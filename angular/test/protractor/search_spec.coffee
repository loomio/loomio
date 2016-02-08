describe 'Search', ->

  page = require './helpers/page_helper.coffee'

  describe 'searching for a thread', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'searches for and loads a thread by title', ->
      page.click('.lmo-navbar__recent')
      page.fillIn('.navbar-search-input', 'what star')
      page.click('.navbar-search-results a.selector-list-item-link')
      page.expectText('.thread-context', "What star sign are you?")
